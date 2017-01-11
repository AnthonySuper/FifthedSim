require 'set'

module FifthedSim
  ##
  # Models a probabilistic distribution.
  class Distribution
    ##
    # Get a distrubtion for a number.
    # This will be a uniform distribution with P = 1 at this number and P = 0 elsewhere.
    def self.for_number(num)
      self.new({num => 1.0})
    end

    def self.for_range(rng)
      size = rng.size.to_f
      e = 1.0 / size
      self.new(Hash[rng.map{|x| [x, e]}])
    end

    def self.for(obj)
      case obj
      when Fixnum
        self.for_number(obj)
      when Range
        self.for_range(obj)
      else
        raise ArgumentError, "can't amke a distribution for that"
      end
    end

    ##
    # We initialize class with a map of results to occurences, and a total number of possible different occurences.
    # Generally, you will not ever initialize this yourself.
    def initialize(map)
      keys = map.keys
      @max = keys.max
      @min = keys.min
      @map = map.dup
      @map.default = 0
    end

    attr_reader :total_possible,
      :min,
      :max


    def range
      (@min..@max)
    end

    def map
      @map.dup
    end

    def average
      map.map{|k, v| k * v}.inject(:+)
    end

    ##
    # Obtain a new distribution of values.
    # When block.call(value) for this distribution is true, we will allow
    # values from the second distribution.
    # Otherwise, the value will be zero.
    #
    # This is mostly used in hit calculation - AKA, if we're higher than an AC, then we hit, otherwise we do zero damage
    def hit_when(other, &block)
      hit_prob = map.map do |k, v|
        if block.call(k)
          v
        else
          nil
        end
      end.compact.inject(:+)
      miss_prob = 1 - hit_prob
      omap = other.map
      h = Hash[omap.map{|k, v| [k, v * hit_prob]}]
      h[0] = (h[0] || 0) + miss_prob
      Distribution.new(h)
    end

    ##
    # Takes a block or callable object.
    # This function will call the callable with all possible outcomes of this distribution.
    # The callable should return another distribution, representing the possible values when this possibility happens.
    # This will then return a value of those possibilities.
    #
    # An example is probably helpful here.
    # Let's consider the case where a monster with +0 to hit is attacking a creature with AC 16 for 1d4 damage, and crits on a 20.
    # If we want a distribution of possible outcomes of this attack, we can do:
    #
    #   1.d(20).distribution.results_when do |x|
    #     if x < 16
    #       Distribution.for_number(0)
    #     elseif x < 20
    #       1.d(4).distribution
    #     else
    #       2.d(4).distribution
    #     end
    #   end
    def results_when(&block)
      h = Hash.new{|h, k| h[k] = 0}
      range.each do |v|
        prob = @map[v]
        o_dist = block.call(v)
        o_dist.map.each do |k, v|
          h[k] += (v * prob)
        end
      end
      Distribution.new(h)
    end

    def percent_within(range)
      percent_where{|x| range.contains? x}
    end

    def percent_where(&block)
      @map.to_a
        .keep_if{|(k, v)| block.call(k)}
        .map{|(k, v)| v}
        .inject(:+)
    end

    def percent_exactly(num)
      return 0 if num < @min || num > @max
      @map[num] || 0
    end

    def variance
      avg = average
      @map.map do |k, v|
        ((k - avg)**2) * v
      end.inject(:+)
    end

    def std_dev
      Math.sqrt(variance)
    end

    def percent_least(num)
      return 0 if num < @min
      return 1 if num >= @max
      @min.upto(num).map(&map_proc).inject(:+)
    end

    def percent_greater(num)
      return 0 if num > @max
      return 1 if num >= @min
      num.upto(@max).map(&map_proc).inject(:+)
    end

    def convolve(other)
      h = {}
      abs_min = [@min, other.min].min
      abs_max = [@max, other.max].max
      min_possible = @min + other.min
      max_possible = @max + other.max
      # TODO: there has to be a less stupid way to do this right?
      v = min_possible.upto(max_possible).map do |val|
        sum = abs_min.upto(abs_max).map do |m|
          percent_exactly(m) * other.percent_exactly(val - m)
        end.inject(:+)
        [val, sum]
      end
      self.class.new(Hash[v])
    end

    ##
    # Get the distribution of a result from this distribution divided by
    # one from another distribution.
    # If the other distribution may contain zero this will break horribly.
    def convolve_divide(other)
      throw ArgumentError, "Divisor may be zero" if other.min < 1
      h = Hash.new{|h, k| h[k] = 0}
      # We can do this faster using a sieve, but be lazy for now
      # TODO: Be less lazy
      range.each do |v1|
        other.range.each do |v2|
          h[v1 / v2] += percent_exactly(v1) * other.percent_exactly(v2)
        end
      end
      self.class.new(h)
    end

    def convolve_greater(other)
      h = Hash.new{|h, k| h[k] = 0}
      # for each value
      range.each do |s|
        (s..other.max).each do |e|
          h[e] += (other.percent_exactly(e) * percent_exactly(s))
        end
        h[s] += (other.percent_least(s - 1) * percent_exactly(s))
      end
      self.class.new(h)
    end

    def convolve_less(other)
      h = Hash.new{|h, k| h[k] = 0}
      range.each do |s|
        (other.min..s).each do |e|
          h[e] += (other.percent_exactly(e) * percent_exactly(s))
        end
        h[s] += (other.percent_greater(s + 1) * percent_exactly(s))
      end
    end

    COMPARE_EPSILON = 0.00001
    def ==(other)
      omap = other.map
      max_possible = (@max / other.min)
      same_keys = (Set.new(@map.keys) == Set.new(omap.keys))
      same_vals = @map.keys.each do |k|
        (@map[k] - other.map[k]).abs <= COMPARE_EPSILON
      end
      same_keys && same_vals
    end

    def text_histogram(cols = 60)
      max_width = @max.to_s.length
      justwidth = max_width + 1
      linewidth = (cols - justwidth)
      range.map do |v|
        "#{v}:".rjust(justwidth) + ("*" * (percent_exactly(v) * linewidth))
      end.join("\n")
    end

    private
    def map_proc
      return Proc.new do |arg|
        res = @map[arg]
      end
    end
  end
end
