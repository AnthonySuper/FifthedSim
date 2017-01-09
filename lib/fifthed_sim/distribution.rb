module FifthedSim
  class Distribution

    def self.for_number(num)
      self.new({num => 1}, 1)
    end

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
      h = Hash.new{|hash, key| hash[key] = 0}
      m = other.map
      @map.each do |k, v|
        m.each do |k2, v2|
          key = k + k2
          h[key] = h[key] + ((v + v2) / 2)
        end
      end
      self.class.new(h,@total_possible * other.total_possible)
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
