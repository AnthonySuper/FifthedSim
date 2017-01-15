require "stringscanner"
module FifthedSim
  class ExpressionParser
    def initialize(str)
      @scan = StringScanner.new(str)
      @exp = []
    end
  end
end
