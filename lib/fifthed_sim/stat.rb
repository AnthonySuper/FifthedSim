module FifthedSim
  class Stat
    def initialize(hash)
      @value = hash[:value]
      @save_mod = (hash[:save_mod] || mod)
    end

    def mod
      (@value - 10) / 2
    end

    def save_mod
      @save_mod
    end

    def saving_throw
      1.d(20) + save_mod
    end
  end
end
