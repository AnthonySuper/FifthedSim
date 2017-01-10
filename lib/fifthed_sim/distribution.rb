module FifthedSim
  ##
  # Models a probabilistic distribution.
  class Distribution
    ##
    # Get a distrubtion for a number.
    # This will be a uniform distribution with P = 1 at this number and P = 0 elsewhere.
    def self.for_number(num)
      self.new({num => 1}, 1)
    end

    ##
    # We initialize class with a map of results to occurences, and a total number of possible different occurences.
    # Generally, you will not ever initialize this yourself.
    def initialize(map, total_possible)
      keys = map.keys
      @max = keys.max
      @min = keys.min
      @map = map
      @total_possible = total_possible
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

    def probability_map
      Hash[@map.map{|k, v| [k, v / @total_possible.to_f]}]
    end

    def percent_exactly(num)
      return 0 if num < @min || num > @max
      @map[num] / @total_possible.to_f
    end

    def percent_least(num)
      return 0 if num < @min
      return 1 if num >= @max
      
      n = @min.upto(num).map(&map_proc).inject(:+)
      n / @total_possible.to_f
    end

    def convolve(other)
      h = {}
      abs_min = [@min, other.min].min
      abs_max = [@max, other.max].max
      min_possible = @min + other.min
      max_possible = @max + other.max
      tp = @total_possible * other.total_possible
      # TODO: there has to be a less stupid way to do this right?
      v = min_possible.upto(max_possible).map do |val|
        sum = abs_min.upto(abs_max).map do |m|
          percent_exactly(m) * other.percent_exactly(val - m)
        end.inject(:+)
        [val, (sum * tp).to_i]
      end
      self.class.new(Hash[v], tp)
    end

    def ==(other)
      @map == other.map &&
        @total_possible == other.total_possible
    end

    private
    def map_proc
      return Proc.new do |arg|
        res = @map[arg]
      end
    end
  end
end
