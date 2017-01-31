require_relative '../dice_expression'

module FifthedSim
  class AdditionNode < DiceExpression

    def initialize(lhs, rhs)
      @lhs, @rhs = lhs, rhs
    end

    def value
      @lhs.value + @rhs.value
    end

    def dice
      self.class.new(*@components.find_all{|x| x.is_a?(RollNode)})
    end

    def distribution
      @lhs.distribution.convolve(@rhs.distribution)
    end

    def reroll
      self.class.new(@lhs.reroll, @rhs.reroll)
    end


    def value_equation(terminal: false)
      lhs = @lhs.value_equation(terminal: terminal)
      rhs = @rhs.value_equation(terminal: terminal)
      "(#{lhs} + #{rhs})"
    end

    def expression_equation
      "(" + [@lhs, @rhs].map do |c|
        c.expression_equation
      end.join(" + ") + ")"
    end
  end
end
