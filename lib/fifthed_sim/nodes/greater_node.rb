require_relative '../dice_expression'

module FifthedSim
  class GreaterNode < DiceExpression
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

    def min
      [@lhs.min, @rhs.min].max
    end

    def max
      [@lhs.max, @rhs.max].max
    end

    def value_equation(terminal: false)
      lhs = @lhs.value_equation(terminal: terminal)
      rhs = @rhs.value_equation(terminal: terminal)
      "max(#{lhs}, #{rhs}"
    end

    def expression_equation
      "max(#{lhs.expression_equation}, #{rhs.expression_equation})"
    end
  end
end
