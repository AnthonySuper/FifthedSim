module FifthedSim
  ##
  # Model an attack vs AC
  class Attack

    class DefinitionProxy
      def initialize(name, &block)
        @attrs = {
          name: name,
          modifier: "",
          damage: nil,
          crit_threshold: 20
        }
        instance_eval(&block)
      end

      attr_reader :attrs

      def modifier(num)
        @attrs[:modifier] = num
      end

      def damage(dmg)
        @attrs[:damage] = dmg
      end

      def crit_threshold(thr)
        @attrs[:crit_threshold] = thr
      end
    end

    def self.define(name, &block)
      d = DefinitionProxy.new(name, &block)
      self.new(d.attrs)
    end

    def initialize(attrs)
      @name = attrs[:name]
      @to_hit= 1.d(20) + attrs[:modifier]
      @damage = attrs[:damage]
      @crit_threshold = attrs[:crit_threshold]
    end

    def hit_distribution(other)
      ac = other.ac
      to_hit.distribution.results_when do |x|
        if x < ac
          Distribution.for_value(0)
        elsif x < @crit_threshold
          @damage.distribution
        else
          (@damage + @damage.dice).distribution
        end
      end
    end

    attr_reader :to_hit, :damage
  end
end
