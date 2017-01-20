require_relative '../dice_expression'

module FifthedSim
  ##
  # Normally we handle numbers by use of a refinement on Fixnum
  # However, in some cases, we may have the fixnum as the *start* of an expression.
  # In this case, we have a problem, because Fixnum#+ is not overloaded to return a DiceNode.
  # In this case, we must use this, a NumberNode.
  # NumberNodes wrap a number.
  class NumberNode < DiceExpression
    def initialize(arg)
      unless arg.is_a? Fixnum
        raise ArgumentError, "#{arg.inspect} is not a fixnum"
      end
      @value = arg
    end

    def distribution
      Distribution.for(@value)
    end

    def value
      @value
    end

    def reroll
      self.class.new(@value)
    end

    def value_equation(terminal: false)
      @value.to_s
    end

    def expression_equation
      @value.to_s
    end
  end
end
