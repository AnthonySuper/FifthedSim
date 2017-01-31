require_relative '../dice_expression'
module FifthedSim
  class SubtractionNode < DiceExpression
    def initialize(lhs, rhs)
      @lhs = lhs
      @rhs = rhs
    end

    def value
      @lhs.value - @rhs.value
    end

    def reroll
      self.class.new(@lhs.reroll, @rhs.reroll)
    end

    def distribution
      @lhs.distribution.convolve_subtract(@rhs.distribution)
    end

    define_binary_op_equations "-"
  end
end
