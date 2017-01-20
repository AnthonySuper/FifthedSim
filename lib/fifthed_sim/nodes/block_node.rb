require_relative '../dice_expression'
require_relative '../calculated_fixnum'
require_relative '../distribution'

module FifthedSim
  class BlockNode < DiceExpression
    using CalculatedFixnum

    def initialize(arg, &block)
      @arg = arg
      @block = block
      @current_expression = block.call(arg.value)
      @current_value = @current_expression.value
    end

    def value
      @current_value
    end

    def reroll
      self.class.new(@arg.reroll, &@block)
    end

    def distribution
      @arg.distribution.results_when(&distribution_block)
    end

    def value_equation(terminal: false)
      arg = @arg.value_equation(terminal: terminal)
      ce = @current_expression.value_equation(terminal: terminal)
      "blockNode(#{arg} => #{ce})"
    end

    protected

    def distribution_block
      h = Hash[@arg.range.map do |k|
        [k, @block.call(k).distribution]
      end]
      require 'pry'
      proc do |x|
        h.fetch(x)
      end
    end
  end
end
