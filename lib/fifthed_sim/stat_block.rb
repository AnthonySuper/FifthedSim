module FifthedSim
  class StatBlock
    STAT_TYPES = [:str,
                  :dex,
                  :wis,
                  :con,
                  :int]

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
