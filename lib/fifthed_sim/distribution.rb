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
      (@max..@min)
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

    def percent_least(num)
      return 0 if num < @min
      return 1 if num >= @max
      @min.upto(num).map(&map_proc).inject(:+)
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

    COMPARE_EPSILON = 0.00001
    def ==(other)
      omap = other.map
      same_keys = (Set.new(@map.keys) == Set.new(omap.keys))
      same_vals = @map.keys.each do |k|
        (@map[k] - other.map[k]).abs <= COMPARE_EPSILON
      end
      same_keys && same_vals
    end

    private
    def map_proc
      return Proc.new do |arg|
        res = @map[arg]
      end
    end
  end
end
