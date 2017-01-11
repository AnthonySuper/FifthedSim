require_relative '../distribution'
require_relative '../dice_expression'

##
# We sneakily monkey-patch Fixnum here, to allow us to use a nice syntax
# for factorials.
#
# We only do this if somebody hasn't done it already, in case ruby adds this to the standard one day.
class Fixnum
  unless self.instance_methods(:false).include?(:factorial)
    ## 
    # Mathematical factorial
    def factorial
      (1..self).inject(:*) || 1
    end
  end
end


##
# Mathemetical combination
def combination(n, r)
  n.factorial / (r.factorial * (n - r).factorial)
end  

module FifthedSim
  ##
  # This class models the result of a roll of multiple dice.
  # It is filled with the actual result of randomly-rolled dice, but contains
  # methods to enable the calculation of average values.
  class MultiNode < DiceExpression
    def self.d(num, type)
      self.new(num.times.map{RollNode.roll(type)})
    end

    ## 
    # Generally, don't calculate this yourself
    def initialize(array)
      unless array.is_a?(Array) && ! array.empty?
        raise ArgumentError, "Not a valid array"
      end
      unless array.all?{|elem| elem.is_a?(RollNode) }
        raise ArgumentError, "Not all die rolls"
      end
      @array = array
    end

    def reroll
      self.class.new(@array.map(&:reroll))
    end

    ##
    # Did any of our dice crit?
    def has_crit?
      @array.any?(&:crit?)
    end

    ##
    # Did any of our dice critically fail?
    def has_critfail?
      @array.any?(&:critfail?)
    end

    ##
    # What is the theoretical average value when we roll this many dice?
    def average
      @array.map(&:average).inject(:+)
    end
 
    ##
    # Obtain an actual array of dice.
    # Will likely be rarely used.
    def dice
      @array.dup
    end

    ##
    # Calculate the value of these dice
    def value
      @array.map(&:value).inject(:+)
    end

    ##
    # How many dice did we roll?
    def roll_count
      @array.count
    end

    ## 
    # What kind of dice did we roll?
    def dice_type
      @array.first.type
    end

    ##
    # The minimum value we could have rolled
    def min_value
      roll_count
    end

    ##
    # The maximum value we could have rolled 
    def max_value
      dice_type * roll_count
    end

    ## 
    # Obtain a probability distribution for when we roll this many dice.
    # This is an instnace of the Distribution class.
    def distribution
      total_possible = (dice_type ** roll_count)
      mapped = min_value.upto(max_value).map do |k|
        [k, (occurences(k) / total_possible.to_f)]
      end
      Distribution.new(Hash[mapped])
    end

    private

    def occurences(num)
      dice_type = @array.first.type
      num_dice = @array.size
      0.upto((num - num_dice) / dice_type).map do |k|
        ((-1) ** k) * 
          combination(num_dice, k) *
          combination(num - dice_type*k - 1, num_dice- 1)
      end.inject(:+)
    end
  end
end
