module FifthedSim

  ## 
  # Prependable module
  module Serialized
    def self.prepended(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def attribute(name, klass, 
                    required: true,
                    default: nil)
        @attr_map ||= {}
        @attr_map[name] = {klass: klass, 
                           required: required,
                           default: default}
      end

      def serialized_attributes
        @attr_map.dup
      end

      def serialized_convert(name, obj)
        klass = @attr_map[name][:klass]
        allow_nil = @attr_map[name][:allow_nil]
        name = klass.name.split("::").last
        if obj.nil?
          return nil
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

      def has_serialized_default? k
        ! @attr_map[k][:default].nil?
      end

      def serialized_default k
        @attr_map[k][:default]
      end

      def define(&block)
        h = self.definition_proxy.new(&block)
        self.new(h.get_attrs)
      end

      def definition_proxy
        @definition_proxy ||= make_definition_proxy
        @definition_proxy
      end

      def make_definition_proxy
        Serialized::DefinitionProxy.create(@attr_map)
      end
    end

    def initialize(hash)
      if hash.is_a? Hash
        h = self.class.serialized_attributes.map do |k, v|
          value = if hash.has_key?(k)
                    hash[k]
                  elsif self.class.has_serialized_default? k
                    self.class.serialized_default(k)
                  elsif self.class.attribute_optional? k
                    nil
                  else
                    raise ArgumentError, "Parameter #{k} missing"
                  end
          conv = self.class.serialized_convert(k, value)
          [k, conv]
        end.compact
        h.map! do |k, v|
          if v.nil? && self.class.attribute_optional?(k) then
            nil
          else
            [k, v]
          end
        end.compact!
        super(Hash[h])
      else
        super(hash)
      end
    end
  end
end

require_relative './serialized/definition_proxy'
