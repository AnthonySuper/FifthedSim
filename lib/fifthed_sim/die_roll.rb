require_relative './helpers/average_comparison'

module FifthedSim
  class DieRoll
    include AverageComparison

    def self.roll(type)
      raise ArgumentError, "Must be an Integer" unless type.is_a? Fixnum
      self.new(SecureRandom.random_number(type - 1) + 1, type)
    end

    # Obtain a DieRoll filled with the average result of this die type
    # This will round down.
    def self.average(type)
      self.new((type + 1) / 2, type)
    end

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

    attr_reader :value, :type

    def average
      (@type + 1) / 2.0
    end

    def difference_from_average
      @value - average
    end

    def critfail?
      @value == 1
    end

    def crit?
      @value == @type
    end

    def to_i
      @value
    end

    def to_f
      @value.to_f
    end

    def method_missing(method, *args, **kwards, &block)
      if @value.respond_to? method
        @value.public_send(method,*args,**kwards,&block)
      else
        super
      end 
    end
  end
end
