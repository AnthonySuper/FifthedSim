require_relative '../dice_expression'
require_relative '../calculated_fixnum'

module FifthedSim
  class GreaterNode < DiceExpression
    using CalculatedFixnum
    def initialize(lhs, rhs)
      @lhs, @rhs = lhs, rhs
    end

    def value
      [@lhs.value, @rhs.value].max
    end

    def distribution
      @lhs.distribution.convolve_greater(@rhs.distribution)
    end

    def reroll
      self.class.new(@lhs.reroll, @rhs.reroll)
    end
  end
end
