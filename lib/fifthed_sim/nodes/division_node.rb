require_relative '../dice_expression'
require_relative '../calculated_fixnum'
module FifthedSim
  class DivisionNode < DiceExpression
    using CalculatedFixnum

    def initialize(num, div)
      @num = num
      @div = div
    end

    def value
      @num.value / @div.value
    end

    def reroll
      self.class.new(@num.reroll, @div.reroll)
    end

    def distribution
      @num.distribution.convolve_divide(@div.distribution)
    end
  end
end
