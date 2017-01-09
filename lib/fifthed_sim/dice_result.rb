module FifthedSim
  class DiceResult
    def initialize(array)
      @array = array
    end

    def to_i
      @array.map(&:to_i).inject(:+)
    end

    def to_f
      @array.map(&:to_f).inject(:+)
    end

    def value
      to_i
    end
  end
end
