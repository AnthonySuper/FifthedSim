require 'json'
module FifthedSim

  class SerializationError < StandardError
  end

  class FifthSerial

    class RegistrationError < StandardError
    end

    ATOMS = [Numeric, String, NilClass].freeze

    def self.register symname, klass
      raise RegistrationError, 
        "Can't use to deserialize" unless klass.respond_to?(:from_fifth_serial)
      serialtable[symname.to_sym] = klass
    end

    def self.is_atom? obj
      ATOMS.any?{|atom| atom === obj}
    end

    def self.load obj
      return obj if is_atom?(obj)
      if obj.is_a? Hash
        return from_hash(obj)
      elsif obj.is_a? Array
        return from_array(obj)
      else
        raise SerializationError, 
          "#{obj.class} cannot be loaded (not a hash or atom)"
      end
    end

    def self.dump obj
      return obj if is_atom?(obj)
      hash = self.shallow_dump(obj)
      fully_serial = Hash[hash.map do |k, v|
        [k, self.dump(v)]
      end]
      fully_serial["fifth_serial_class"] = sym_name(obj)
      fully_serial
    end

    def self.shallow_dump obj
      return obj if obj.is_a? Hash
      %w(to_fifth_serial to_h).each do |type|
        return obj.__send__(type) if obj.respond_to?(type)
      end
      raise SerializationError,
        "#{obj.class} cannot be dumped (not a hash or atom)"
    end

    def self.can_serialize? obj
      klass = if obj.is_a? Class
                obj
              else
                obj.class
              end
      serialtable.has_value? klass
    end

    protected

    def self.from_hash(hash)
      klass = self.class_for_hash(hash)
      return klass.from_fifth_serial(Hash[hash.map do |k, v|
        next if k == "fifth_serial_class"
        [k.to_sym, self.load(v)]
      end.compact])
    end

    def self.from_array obj
      obj.map{|x| self.load(x)}
    end

    def self.sym_name(obj)
      key = serialtable.key(obj.class)
      raise SerializationError,
        "Class #{obj.class} cannot be dumped" unless key
      key
    end

    def self.serialtable
      @serialtable ||= {}
    end

    def self.class_for_hash(hash)
      self.class_for_key(hash["fifth_serial_class"].to_sym)
    end

    def self.class_for_key(key)
      klass = serialtable[key]
      raise SerializationError,
        "Class #{key} not registered" unless key
      klass
    end
  end
end
