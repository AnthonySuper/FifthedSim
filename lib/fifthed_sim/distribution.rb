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
  end
end
