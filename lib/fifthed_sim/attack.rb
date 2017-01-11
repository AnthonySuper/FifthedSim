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
          crit_threshold: 20,
          crit_damage: nil
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

      def crit_damage(cr)
        @attrs[:crit_damage] = cr
      end
    end

    def self.define(name, &block)
      d = DefinitionProxy.new(name, &block)
      self.new(d.attrs)
    end

    def initialize(attrs)
      @name = attrs[:name]
      @modifier = attrs[:modifier]
      @to_hit= 1.d(20) + attrs[:modifier]
      @damage = attrs[:damage]
      @crit_threshold = attrs[:crit_threshold]
      @crit_damage = (attrs[:crit_damage] || default_crit_damage)
    end

    def default_crit_damage
      if @damage.is_a? MultiNode
        (@damage + @damage)
      else
        @damage + @damage.dice
      end
    end

    def hit_distribution(other)
      ac = other.ac
      to_hit.distribution.results_when do |x|
        if x < ac
          Distribution.for_number(0)
        # A normal hit is greater than AC, but lower than a crit
        elsif x > ac && x < (@crit_threshold + @modifier)
          @damage.distribution
        else
          @crit_damage.distribution
        end
      end
    end

    attr_reader :to_hit, :damage
  end
end
