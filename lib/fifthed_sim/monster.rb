module FifthedSim
  class Monster
    class DefinitionProxy
      def initialize(name, &block)
        @attrs = {
          name: name,
          attacks: {},
          spells: [],
          ac: 0
        }
        instance_eval(&block)
      end

      attr_reader :attrs

      def attack(name, &block)
        if block_given && name.is_a?(String)
          @attrs[:attacks][name] = Attack.define(name, &block)
        elsif name.is_a?(Attack)
          @attrs[:attacks][name.name] << name
        else
          raise ArgumentError, "must be an attack"
        end
      end

      def ac(num)
        @attrs[:ac] = ac
      end
    end

    def self.define(name, &block)
      d = DefinitionProxy.new(name, &block)
      return self.new(d.attrs)
    end

    ASSIGNABLE_ATTRS = [:ac, 
                        :name, 
                        :attacks, 
                        :spells]
    def initialize(attrs)
      attrs.to_a.keep_if{ |(k, v)| ASSIGNABLE_ATTRS.contains?(v) }
        .each { |(k, v)| self.instance_variable_set("@#{k}", v) }
    end

    def random_attack
      @attacks.keys.sample
    end

    attr_reader :ac,
      :name,
      :attacks,
      :spells
  end
end
