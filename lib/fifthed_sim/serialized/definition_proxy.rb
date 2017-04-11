module FifthedSim
  module Serialized
    module DefinitionProxy
      def self.create(hash)
        klass = Class.new
        klass.send :class_eval, <<-EORUBY, __FILE__, __LINE__ + 1
          def initialize(&block)
            @hash = {}
            instance_eval(&block)
          end
        EORUBY
        klass.send :class_eval, <<-EORUBY, __FILE__, __LINE__ + 1
          def get_attrs
            @hash
          end
        EORUBY
        hash.each do |k, v|
          klass.send(:define_method, k, self.create_method(k, v))
        end
        klass
      end

      def self.create_method(name, value)
        Proc.new do |val = nil, &block|
          h = instance_variable_get(:@hash)
          if block
            h[name] = value[:klass].define(&block)
          else
            h[name] = val
          end
        end
      end
    end
  end
end
