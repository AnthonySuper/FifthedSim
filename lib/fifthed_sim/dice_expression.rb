module FifthedSim
  ##
  # This is an abstract dice expression class
  class DiceExpression

    def to_i
      value
    end

    def to_f
      value.to_f
    end

    def average
      distribution.average
    end

    def +(other)
      AdditionNode.new(self, other)
    end


    {"above_" => :>, "below_" => :<, "" => :==}.each do |k,v|
      define_method "#{k}average?" do
        value.public_send(v, average)
      end
    end

    ##
    # Get this difference of the average value and the current value.
    # For example, if the average is 10 and we have a value of 20, it will return 10.
    # Meanwhile, if the average is 10 and we have a value of 2, it will return -8.
    def difference_from_average
      value - average
    end
  end
end

require_relative './nodes/multi_node'
require_relative './nodes/addition_node'
require_relative './nodes/roll_node'
