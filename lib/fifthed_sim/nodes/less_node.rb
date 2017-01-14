require_relative '../dice_expression'
require_relative '../calculated_fixnum'

module FifthedSim
  class LessNode < DiceExpression
    using CalculatedFixnum

    def initialize(lhs, rhs)
      @lhs, @rhs = lhs, rhs
    end

    def value
      [@lhs.value, @rhs.value].min
    end

    def reroll
      self.class.new(@lhs.reroll, @rhs.reroll)
    end

    def max
      [@lhs.max, @rhs.max].min
    end

    def min
      [@lhs.min, @rhs.min].min
    end

    def distribution
      @lhs.distribution.convolve_least(@rhs.distribution)
    end
  end
end
