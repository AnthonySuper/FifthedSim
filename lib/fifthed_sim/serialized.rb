module FifthedSim

  ## 
  # Prependable module
  module Serialized
    def self.prepended(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def attribute(name, klass, allow_nil: false, required: true)
        @attr_map ||= {}
        @attr_map[name] = {klass: klass, 
                           allow_nil: allow_nil,
                           required: required}
      end

      def serialized_attributes
        @attr_map.dup
      end

      def serialized_convert(name, obj)
        klass = @attr_map[name][:klass]
        allow_nil = @attr_map[name][:allow_nil]
        name = klass.name.split("::").last
        if obj.nil?
          raise ArgumentError, "Cannot be nil" unless allow_nil
          obj
        elsif klass === obj
          obj
        elsif respond_to?(name.to_sym, true)
          send(name, obj)
        elsif klass.respond_to? :new
          klass.new(obj)
        else
          raise RuntimeError, "Conversion not possible."
        end
      end

      def attribute_optional? attr
        ! @attr_map[attr][:required]
      end
    end

    def initialize(hash)
      if hash.is_a? Hash
        h = self.class.serialized_attributes.map do |k, v|
          unless hash.has_key?(k)
            if self.class.attribute_optional?(k)
              next
            else
              raise ArgumentError, "Hash needs key #{k}"
            end
          end
          sym = k.to_sym
          conv = self.class.serialized_convert(sym, hash[sym])
          [sym, conv]
        end.compact
        super(Hash[h])
      else
        super(hash)
      end
    end
  end
end
