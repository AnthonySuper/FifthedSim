module FifthedSim
  class Actor
    class DefinitionProxy
      def initialize(name, &block)
        @attrs = {
          name: name,
          attacks: {},
          spells: {},
          base_ac: 10
        }
        instance_eval(&block)
      end

      attr_reader :attrs

      def attack(name, &block)
        if block_given? && name.is_a?(String)
          @attrs[:attacks][name] = Attack.define(name, &block)
        elsif name.is_a?(Attack)
          @attrs[:attacks][name.name] << name
        else
          raise ArgumentError, "must be an attack"
        end
      end

      def spell(name, &block)
        if block_given? && name.is_a?(String)
          @attrs[:spells][name] = Spell.define(name, &block)
        elsif name.is_a?(Spell)
          @attrs[:spells][name.name] << name
        else
          raise ArgumentError, "must be a spell"
        end
      end

      def stats(n = nil, &block)
        if n && n.is_a?(StatBlock)
          @attrs[:stats] = n
        elsif block
          @attrs[:stats] = StatBlock.define(&block)
        else
          raise ArgumentError, "Must be a statblock"
        end
      end

      def base_ac(num)
        @attrs[:base_ac] = num
      end
    end

    def self.define(name, &block)
      d = DefinitionProxy.new(name, &block)
      return self.new(d.attrs)
    end

    ASSIGNABLE_ATTRS = [:base_ac, 
                        :name, 
                        :attacks, 
                        :spells]
    def initialize(attrs)
      attrs.to_a.keep_if{ |(k, v)| ASSIGNABLE_ATTRS.include?(v) }
        .each { |(k, v)| self.instance_variable_set("@#{k}", v) }
    end

    def random_attack
      @attacks.keys.sample
    end

    ##
    # TODO: Implement armor
    def ac
      base_ac
    end

    attr_reader :base_ac,
      :name,
      :attacks,
      :spells
  end
end
