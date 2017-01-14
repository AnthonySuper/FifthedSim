module FifthedSim
  class DamageTypes
    def self.convert(t)
      ret = case t
            when String
              t.to_sym
            when Symbol
              t
            else
              raise ArgumentError, "Cannot convert to damage type"
            end
      unless self.valid_damage_type?(ret)
        raise InvalidDamageType, "#{ret} is not a type of damage"
      end
      ret
    end

    def self.valid_damage_type?(sym)
      DAMAGE_TYPES.include? sym
    end

    class InvalidDamageType < StandardError
    end
  end

  DAMAGE_TYPES = %i(slashing
                    bludgeoning
                    piercing
                    fire
                    cold
                    poison
                    acid
                    psychic
                    necrotic
                    radiant
                    lightning
                    thunder
                    force)
end
