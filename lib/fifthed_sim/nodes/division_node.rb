require_relative '../dice_expression'
module FifthedSim
  class DivisionNode < DiceExpression

    def initialize(num, div)
      @lhs = num
      @rhs = div
    end

    def value
      @lhs.value / @rhs.value
    end

    def reroll
      self.class.new(@lhs.reroll, @rhs.reroll)
    end

    def distribution
      @lhs.distribution.convolve_divide(@rhs.distribution)
    end

    define_binary_op_equations "/"
  end
end
