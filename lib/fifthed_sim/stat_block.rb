require_relative './stat'

module FifthedSim
  STAT_TYPES = [:str,
                :dex,
                :wis,
                :cha,
                :con,
                :int]
  class StatBlock


    class DefinitionProxy
      def initialize(&block)
        @hash = {}
        instance_eval(&block)
      end

      STAT_TYPES.each do |type|
        self.send(:define_method, type) do |x = nil, &block|
          if block
            @hash[type] = Stat.define(&block)
          elsif x.is_a?(Stat)
            @hash[type] = x
          elsif x.is_a?(Fixnum)
            @hash[type] = Stat.from_value(x)
          else
            raise ArgumentError, "not a stat"
          end
        end
      end

      attr_accessor :hash
    end

    def self.define(&block)
      h = DefinitionProxy.new(&block)
      self.new(h.hash)
    end

    def initialize(hash)
      @hash = Hash[hash.map do |k, v|
        if v.is_a?(Stat)
          [k, v]
        else
          [k, Stat.new(v)]
        end
      end]
    end

    STAT_TYPES.each do |st|
      self.send(:define_method, st) do
        @hash[st]
      end
    end
  end
end
