module FifthedSim
  class Stat
    class DefinitionProxy
      def initialize(&block)
        @hash = {
          mod_bonus: 0,
          save_mod: 0
        }
        instance_eval(&block)
      end

      %i(value mod_bonus save_mod).each do |e|
        self.send(:define_method, e) do |x|
          @hash[e] = x
        end
      end

      attr_reader :hash
    end

    def self.define(&block)
      h = DefinitionProxy.new(&block).hash
      self.new(h)
    end

    def self.from_value(h)
      raise ArgumentError, "#{h} not fixnum" unless h.is_a?(Fixnum)
      self.new({value: h, save_mod: 0, mod_bonus: 0})
    end

    def initialize(hash)
      @value = hash[:value]
      @mod_bonus = (hash[:mod_bonus] || 0)
      @save_mod = (hash[:save_mod] || mod)
    end

    attr_reader :value,
      :save_mod,
      :mod_bonus

    def mod
      ((@value - 10) / 2) + @mod_bonus
    end

    def saving_throw
      1.d(20) + save_mod
    end
  end
end
