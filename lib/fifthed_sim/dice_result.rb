require_relative './helpers/average_comparison'
require_relative './distribution'

class Fixnum
  def factorial
    (1..self).inject(:*) || 1
  end
end

def combination(n, r)
  n.factorial / (r.factorial * (n - r).factorial)
end  

module FifthedSim
  ##
  # This class models the result of a dice roll.
  # It is filled with the actual result of randomly-rolled dice, but contains
  # methods to enable the calculation of average values.
  # 
  # When you add a modifier it becomes a DiceCalculation.
  class DiceResult
    def self.d(num, type)
      self.new(num.times.map{DieRoll.roll(type)})
    end

    include AverageComparison

    def initialize(array)
      unless array.is_a?(Array) && ! array.empty?
        raise ArgumentError, "Not a valid array"
      end
      unless array.all?{|elem| elem.is_a?(DieRoll) }
        raise ArgumentError, "Not all die rolls"
      end
      @array = array
    end

    def has_crit?
      @array.any?(&:crit?)
    end

    def average
      @array.map(&:average).inject(:+)
    end

    def has_critfail?
      @array.any?(&:critfail?)
    end

    def dice
      @array.dup
    end

    def to_i
      @array.map(&:to_i).inject(:+)
    end

    def to_f
      to_i.to_f
    end

    def value
      to_i
    end

    def +(other)
      a = DiceCalculation.new(self)
      (a + other)
    end

    def roll_count
      @array.count
    end

    def dice_type
      @array.first.type
    end


    def min_value
      roll_count
    end

    def max_value
      dice_type * roll_count
    end

    def distribution
      total_possible = (dice_type ** roll_count)
      mapped = min_value.upto(max_value).map do |k|
        [k, occurences(k)]
      end
      Distribution.new(Hash[mapped], total_possible)
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
