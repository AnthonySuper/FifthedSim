module FifthedSim
  class Distribution
    def initialize(map, total_possible)
      keys = map.keys
      @max = keys.max
      @min = keys.min
      @map = map
      @total_possible = total_possible
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

    private
    def map_proc
      return Proc.new do |arg|
        res = @map[arg]
      end
    end
  end
end
