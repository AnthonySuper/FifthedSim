module FifthedSim
  ##
  # Spells model save-or-take-damage stuff.
  # At some point in the future I hope to modify them so they work as other stu
  class Spell
    class DefinitionProxy
      ##
      def initialize(name, &block)
        @hash = {
          name: name
        }
        instance_eval(&block)
      end

      %i(damage save_damage).each do |m|
        self.send(:define_method, m) do |damage = nil, &block|
          if block
            @hash[m] = Damage.define(&block)
          elsif damage.is_a?(Damage)
            @hash[m] = damage
          else
            raise ArgumentError, "#{damage} is not damage!"
          end
        end
      end

      def save_dc(n)
        @hash[:save_dc] = n
      end
      
      def save_type(n)
        @hash[:save_type] = n
      end

      def attrs
        @hash
      end
    end

    def self.define(name, &block)
      h = DefinitionProxy.new(name, &block).attrs
      self.new(h)
    end

    def initialize(hash)
      @name = hash[:name]
      @damage = hash[:damage]
      @save_damage = hash[:save_damage]
      @save_type = hash[:save_type]
      @save_dc = hash[:save_dc]
    end

    attr_reader :save_dc,
      :save_type

    def against(other)
      other.saving_throw(@save_type).test_then do |res|
        if res >= @save_dc
          @save_damage
        else
          @damage
        end
      end
    end

    def raw_damage
      @damage.raw
    end

    def raw_save_damage
      @save_damage.raw
    end
  end
end
