require_relative './damage'
require_relative "./fifth_serial"

module FifthedSim
  ##
  # Model an attack vs AC
  class Attack
    class DefinitionProxy
      def initialize(name, &block)
        @attrs = {
          name: name,
          to_hit: 0,
          damage: nil,
          crit_threshold: 20,
          crit_damage: nil
        }
        instance_eval(&block)
      end

      attr_reader :attrs

      def to_hit(num)
        @attrs[:to_hit] = num
      end

      def damage(arg = nil, &block)
        if block_given?
          @attrs[:damage] = Damage.define(&block)
        else
          damage_check(arg)
          @attrs[:damage] = arg
        end
      end

      def crit_damage(arg = nil, &block)
        if block_given?
          @attrs[:crit_damage] = Damage.define(&block)
        else
          damage_check(arg)
        end
      end

      def crit_threshold(thr)
        @attrs[:crit_threshold] = thr
      end

      protected
      def damage_check(arg)
        unless arg.is_a? Damage
          raise TypeError, "#{arg.inspect} is not Damage"
        end
      end
    end

    def self.define(name, &block)
      d = DefinitionProxy.new(name, &block)
      self.new(d.attrs)
    end

    def self.from_fifth_serial(hash)
      self.new(hash)
    end

    def initialize(attrs)
      @name = attrs[:name]
      @to_hit = attrs[:to_hit]
      @damage = attrs[:damage]
      @crit_threshold = attrs[:crit_threshold]
      @crit_damage = attrs[:crit_damage]
    end

    def hit_roll
      1.d(20) + @to_hit
    end

    def against(other)
      hit_roll.test_then do |res|
        if res < other.ac
          0.to_dice_expression
        elsif res > other.ac && res < (@crit_threshold + @to_hit)
          @damage.to(other)
        else
          @crit_damage.to(other)
        end
      end
    end

    def raw_damage
      @damage.raw
    end

    def to_fifth_serial
      Hash[%w(name to_hit damage crit_threshold crit_damage).map do |attr|
        [attr, self.instance_variable_get("@#{attr}")]
      end]
    end
  end

  FifthSerial.register("attack", Attack)
end
