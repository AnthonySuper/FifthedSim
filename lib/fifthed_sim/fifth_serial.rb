require 'json'
module FifthedSim

  class SerializationError < StandardError
  end

  class FifthSerial

    class RegistrationError < StandardError
    end

    ATOMS = [Numeric, String].freeze

    def self.register symname, klass
      @serialtable ||= {}
      raise RegistrationError, 
        "Not a newable object" unless klass.respond_to?(:new)
      @serialtable[symname.to_s] = klass
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
      hash["type"] = sym_name(obj)
      return Hash[hash.map do |k, v|
        [k, self.dump(v)]
      end]
    end

    def shallow_dump obj
      return obj if obj.is_a? Hash
      %w(to_fifth_serial to_h).each do |meth|
        return obj.__send__(obj) if obj.respond_to?(meth)
      end
      raise SerializationError,
        "#{obj.class} cannot be dumped (not a hash or atom)"
    end
        

    protected

    def self.from_hash(obj)
      klass = @serialtable[obj.type.to_s]
      return klass.new(Hash[obj.map do |k, v|
        next if k == "type"
        [k.to_sym, self.load(v)]
      end])
    end

    def self.from_array obj
      obj.map{|x| self.load(x)}
    end

    def self.sym_name(obj)
      @symtable.key(obj.class)
    end
  end
end
