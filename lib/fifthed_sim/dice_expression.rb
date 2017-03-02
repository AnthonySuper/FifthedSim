require 'rainbow'

module FifthedSim
  ##
  # This is an abstract dice expression class
  class DiceExpression

    def to_i
      value
    end

    ## 
    # Allow explicit coerceon
    def to_int
      value
    end

    def coerce(other)
      [NumberNode.new(other), self]
    end

    def to_f
      value.to_f
    end

    def average
      distribution.average
    end

    def +(other)
      AdditionNode.new(self, other.to_dice_expression)
    end

    def -(other)
      SubtractionNode.new(self, other.to_dice_expression)
    end

    def /(other)
      DivisionNode.new(self, other.to_dice_expression)
    end

    def *(other)
      MultiplicationNode.new(self, other.to_dice_expression)
    end

    def or_greater(other)
      GreaterNode.new(self, other.to_dice_expression)
    end

    def or_least(other)
      LessNode.new(self, other.to_dice_expression)
    end

    def percentile
      distribution.percent_lower_equal(value)
    end

    def max
      distribution.max
    end

    def min
      distribution.min
    end

    ##
    # Takes a block, which should take a single argument
    # This block should return another DiceExpression type, based on the result of this DiceExpression.
    def test_then(&block)
      BlockNode.new(self, &block)
    end

    {"above_" => :>, "below_" => :<, "" => :==}.each do |k,v|
      define_method "#{k}average?" do
        value.public_send(v, average.round(4))
      end
    end

    ##
    # Get this difference of the average value and the current value.
    # For example, if the average is 10 and we have a value of 20, it will return 10.
    # Meanwhile, if the average is 10 and we have a value of 2, it will return -8.
    def difference_from_average
      value - average
    end

    def range
      (min..max)
    end

    def to_dice_expression
      self.dup
    end


    def stats
      distribution
    end

    protected

    def self.define_binary_op_equations(op)
      self.send(:define_method, :value_equation) do |terminal: false|
        lhs = instance_variable_get(:@lhs).value_equation(terminal: terminal)
        rhs = instance_variable_get(:@rhs).value_equation(terminal: terminal)
        "(#{lhs} #{op} #{rhs}"
      end

      self.send(:define_method, :expression_equation) do
        lhs = instance_variable_get(:@lhs)
        rhs = instance_variable_get(:@rhs)
        "(#{lhs.expression_equation} #{op} #{rhs.expression_equation})"
      end
    end
  end
end

##
# Allow .to_dice_expression and other needed values on Fixnums
class Fixnum
  def to_dice_expression
    FifthedSim::NumberNode.new(self)
  end
end

class String
  def to_dice_expression
    FifthedSim::Compiler.compile(self)
  end
end

##
# C-style conversion, yay
def DiceExpression(arg)
  return arg.to_dice_expression if arg.respond_to? :to_dice_expression
  raise ArgumentError, "Cannot convert #{arg.class} to DiceExpression"
end
    

require_relative './nodes/multi_node'
require_relative './nodes/addition_node'
require_relative './nodes/roll_node'
require_relative './nodes/block_node'
require_relative './nodes/division_node'
require_relative './nodes/greater_node'
require_relative './nodes/less_node'
require_relative './nodes/number_node'
require_relative './nodes/multiplication_node'
require_relative './nodes/subtraction_node'
