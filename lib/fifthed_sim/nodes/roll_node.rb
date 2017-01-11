require_relative '../dice_expression.rb'

module FifthedSim
  ##
  # Model a single roll of the dice.
  # Users of the library will rarely interact with this class, and will instead manpiulate values based on the DiceResult type.
  #
  class RollNode < DiceExpression

    ##
    # Create a diceresult by rolling a certain type.
    def self.roll(type)
      raise ArgumentError, "Must be an Integer" unless type.is_a? Fixnum
      self.new(SecureRandom.random_number(type - 1) + 1, type)
    end

    ##
    # Obtain a DieRoll filled with the average result of this die type
    # This will round down.
    def self.average(type)
      self.new((type + 1) / 2, type)
    end

    ##
    # Obtain an average value for this die type, as a float
    # We're extremely lazy here.
    def self.average_value(type)
      self.new(1, type).average
    end

    def initialize(val, type)
      unless val.is_a?(Fixnum) && type.is_a?(Fixnum)
        raise ArgumentError, "Type invald"
      end
      @value = val
      @type = type
    end

    def reroll
      self.class.roll(@type)
    end

    attr_reader :value, :type

    ##
    # The average roll for a die of this type
    def average
      (@type + 1) / 2.0
    end

    ##
    # How far away this roll is from the average roll
    def difference_from_average
      @value - average
    end

    ##
    # Is this roll a critical failure? (AKA, is it a 1?)
    def critfail?
      @value == 1
    end

    ##
    # Is this roll a critical? (AKA, is it the max value of the dice?)
    def crit?
      @value == @type
    end

    def distribution
      Distribution.for((1..@type))
    end
  end
end
