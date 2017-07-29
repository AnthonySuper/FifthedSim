require_relative '../dice_expression.rb'
require_relative "../fifth_serial"

module FifthedSim
  ##
  # Model a single roll of the dice.
  # Users of the library will rarely interact with this class, and will instead manpiulate values based on the DiceResult type.
  #
  class RollNode < DiceExpression

    def self.from_fifth_serial(hash)
      self.new(hash[:value], hash[:type])
    end

    ##
    # Create a diceresult by rolling a certain type.
    def self.roll(type)
      raise ArgumentError, "Must be an Integer" unless type.is_a? Fixnum
      self.new(SecureRandom.random_number(type) + 1, type)
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
      raise ArgumentError,
        "val '#{val}' is not fixnum" unless Fixnum === val
      raise ArgumentError,
        "type '#{type}' is not fixnum" unless Fixnum === type
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

    def value_equation(terminal: false)
      return value.to_s unless terminal
      if critfail?
        Rainbow(value.to_s).color(:red).bright.to_s
      elsif crit?
        Rainbow(value.to_s).color(:yellow).bright.to_s
      else
        value.to_s
      end
    end

    def expression_equation
      "d#{@type}"
    end

    def to_fifth_serial
      { value: @value, type: @type }
    end
  end

  FifthSerial.register("roll_node", RollNode)
end
