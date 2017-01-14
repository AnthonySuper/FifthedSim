require_relative './damage_types'
require_relative './calculated_fixnum'
module FifthedSim
  class Damage
    using CalculatedFixnum

    class DefinitionProxy
      def initialize(&block)
        @attrs = {}
        instance_eval(&block)
      end

      attr_accessor :attrs

      DAMAGE_TYPES.each do |type|
        self.send(:define_method, type) do |arg|
          unless arg.is_a?(DiceExpression) || arg.is_a?(Fixnum)
            raise ArgumentError, "Must be a dice throw"
          end
          @attrs[type] = arg
        end
      end
    end

    def self.define(&block)
      h = DefinitionProxy.new(&block).attrs
      self.new(h)
    end

    def initialize(hash)
      @hash = hash
    end

    ##
    # Obtain a dice roll of how much damage we're doing to a particular enemy
    def to(enemy)
      @hash.map do |k, v|
        if enemy.immune_to?(k)
          0.to_dice_expression
        elsif enemy.resistant_to?(k)
          (v / 2)
        else
          v
        end
      end.inject{|sum, k| sum + k}
    end
    
    def raw
      @hash.values.inject{|s, k| s + k}
    end
  end
end
