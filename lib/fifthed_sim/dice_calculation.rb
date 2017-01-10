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

    def distribution
      FifthedSim::Distribution.for_number(self)
    end
  end
end




module FifthedSim
  class DiceCalculation
    include AverageComparison
    using CalculatedFixnum

    def initialize(*values)
      @components = values.flatten.map{|v| check_type(v)}.flatten
    end

    def +(other)
      check_type(other)
      self.class.new(*@components, other)
    end

    def value
      # Symbol::& uses send, so refinements would break
      # How sad
      @components.map{|x| x.value}.inject(:+)
    end

    def dice
      require 'pry'
      binding.pry
      self.class.new(*@components.find_all{|x| x.is_a?(DieRoll)})
    end

    def average
      @components.map{|x| x.average}.inject(:+)
    end

    def has_critfail?
      @components.any?{|x| x.has_critfail?}
    end

    def has_crit?
      @components.any?{|x| x.has_crit?}
    end

    def distribution
      # TODO: Maybe figure out how to minimize convolution expense?
      @components.map{|x| x.distribution}.inject do |memo, p|
        memo.convolve(p)
      end
    end


    private
    ALLOWED_TYPES = [DiceResult,
                     Fixnum,
                     DiceCalculation]

    def check_type(obj)
      case obj
      when Fixnum, DiceResult
        obj
      when DiceCalculation
        obj.components
      else
        raise TypeError, "Did not expect type #{obj.inspect}"
      end
    end  
  end
end
