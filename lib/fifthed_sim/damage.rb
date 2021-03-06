require_relative './damage_types'
module FifthedSim
  class Damage

    class DefinitionProxy
      def initialize(&block)
        @attrs = {}
        instance_eval(&block)
      end

      attr_accessor :attrs

      DAMAGE_TYPES.each do |type|
        self.send(:define_method, type) do |arg|
          @attrs[type] = DiceExpression(arg)
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
      mapped = @hash.map do |k, v|
        if enemy.immune_to?(k)
          0.to_dice_expression
        elsif enemy.resistant_to?(k)
          (v / 2)
        else
          v
        end
      end
      if mapped.empty?
        0.to_dice_expression
      else
        mapped.inject{|memo, x| memo + x}
      end
    end
    
    def raw
      @hash.values.inject{|s, k| s + k}
    end
  end
end
