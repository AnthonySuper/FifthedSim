module FifthedSim
  class Stat
    prepend Serialized

    def define(num = nil, &block)
      if block
        super(&block)
      else
        self.from_value(num)
      end
    end

    attribute :value, Integer
    attribute :mod_bonus, Integer, default: 0
    attribute :save_mod_bonus, Integer, default: 0
    

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
