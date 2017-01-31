require_relative '../dice_expression'

module FifthedSim
  class MultiplicationNode < DiceExpression
    def initialize(lhs, rhs)
      @lhs = lhs
      @rhs = rhs
    end

    def value
      @lhs.value * @rhs.value
    end

    def distribution
      @lhs.distribution.convolve_multiply(@rhs.distribution)
    end

    def reroll
      self.class.new(@lhs.reroll, @rhs.reroll)
    end

    define_binary_op_equations "*"
  end
end
