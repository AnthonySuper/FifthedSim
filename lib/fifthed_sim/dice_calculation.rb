require_relative './helpers/average_comparison'

module CalculatedFixnum
  refine Fixnum do
    include FifthedSim::AverageComparison

    def value
      self
    end

    def average
      self
    end

    def has_critfail?
      false
    end

    def has_crit?
      false
    end

    def distance_from_average
      0
    end
  end
end




module FifthedSim
  class DiceCalculation
    include AverageComparison
    using CalculatedFixnum

    def initialize(*values)
      values.each{|v| check_type(v) }
      @components = values
    end

    def +(other)
      check_type(other)
      @components << other   
      self
    end

    def value
      # Symbol::& uses send, so refinements would break
      # How sad
      @components.map{|x| x.value}.inject(:+)
    end

    def average
      @components.map{|x| x.average}.inject(:+)
    end

    def has_critfail?
      @components.any?(&:has_critfail?)
    end

    def has_crit?
      @components.any?(&:has_crit?)
    end

    private
    ALLOWED_TYPES = [DiceResult,
                     Fixnum]

    def check_type(obj)
      unless ALLOWED_TYPES.any?{|t| obj.is_a?(t) }
        raise TypeError, "not a proper member type"
      end
    end  
  end
end
