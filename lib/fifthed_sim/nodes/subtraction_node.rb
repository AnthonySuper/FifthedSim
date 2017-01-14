require_relative '../dice_expression'
module FifthedSim
  class SubtractionNode < DiceExpression
    using CalculatedFixnum
    def initialize(lhs, rhs)
      @lhs = lhs
      @rhs = rhs
    end

    def value
      @lhs - @rhs
    end

    def reroll
      self.class.new(@lhs.reroll, @rhs.reroll)
    end

    def distribution
      @lhs.distribution.convolve_subtract(@rhs.distribution)
    end
  end
end
