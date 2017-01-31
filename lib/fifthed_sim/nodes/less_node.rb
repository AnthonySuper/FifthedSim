require_relative '../dice_expression'

module FifthedSim
  class LessNode < DiceExpression

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

    def equation_representation
      "min(#{@lhs.equation_representation}, #{@rhs.equation_representation})"
    end

    def value_equation(terminal: false)
      lhs = @lhs.value_equation(terminal: terminal)
      rhs = @rhs.value_equation(terminal: terminal)
      "min(#{lhs}, #{rhs})"
    end

    def expression_equation
      "min(#{@lhs.expression_equation}, #{@rhs.expression_equation})"
    end
  end
end
