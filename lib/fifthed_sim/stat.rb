module FifthedSim
  class Stat
    class DefinitionProxy
      def initialize(&block)
        @hash = {
          mod_bonus: 0,
          save_mod_bonus: 0
        }
        instance_eval(&block)
      end

      %i(value mod_bonus save_mod_bonus).each do |e|
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

    def initialize(at)
      hash = case at
             when Hash
               at
             when Integer
               {value: at}
             else
               raise ArgumentError, "Can't construct"
             end
      @value = hash[:value]
      @mod_bonus = (hash[:mod_bonus] || 0)
      @save_mod_bonus = (hash[:save_mod_bonus] || 0)
    end

    attr_reader :value,
      :save_mod_bonus,
      :mod_bonus

    def mod
      ((@value - 10) / 2) + @mod_bonus
    end

    def saving_throw
      1.d(20) + mod + save_mod_bonus
    end
  end
end
