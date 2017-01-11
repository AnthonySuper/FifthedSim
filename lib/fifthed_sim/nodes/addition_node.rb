require_relative '../dice_expression'
require_relative '../calculated_fixnum'

module FifthedSim
  class AdditionNode < DiceExpression
    using CalculatedFixnum

    def initialize(*values)
      values.each(&method(:check_type))
      @components = values.flatten
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
      self.class.new(*@components.find_all{|x| x.is_a?(RollNode)})
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
    ALLOWED_TYPES = [DiceExpression,
                     Fixnum]

    def check_type(obj)
      unless ALLOWED_TYPES.any?{|x| obj.is_a?(x)}
        raise TypeError, "Not an allowed node type"
      end
    end  
  end
end