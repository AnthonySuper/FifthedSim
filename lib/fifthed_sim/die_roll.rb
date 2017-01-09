module FifthedSim
  class DieRoll

    def self.roll(type)
      raise ArgumentError, "Must be an Integer" unless type.is_a? Fixnum
      self.new(SecureRandom.random_number(type - 1) + 1, type)
    end

    def self.average(type)
      self.new((type + 1) / 2, type)
    end

    def initialize(val, type)
      unless val.is_a?(Fixnum) && type.is_a?(Fixnum)
        raise ArgumentError, "Type invald"
      end
      @value = val
      @type = type
    end

    attr_reader :value, :type

    def average_value
      (@type + 1) / 2
    end

    def below_average?
      @value < average_value
    end

    def above_average?
      @value > average_value
    end

    def average?
      @value == average_value
    end

    def difference_from_average
      @value - average_value
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
