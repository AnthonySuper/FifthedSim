module FifthedSim
  class Compiler
    def self.parse(str)
      begin
        Parser.new.parse(str)
      rescue Parslet::ParseFailed => e
        msg = e.message
        raise CompileError.new(e)
      end
    end

    def self.compile(str)
      tree = self.parse(str)
      transformed = Transform.new.apply(tree)
      if transformed.is_a? DiceExpression
        transformed
      else
        raise TransformError.new(transformed)
      end
    end

    class CompileError < StandardError
      def initialize(err)
        msg = err.message
        super(msg)
        @line = msg.match(/line (\d+)/)[1].to_i
        @char = msg.match(/char (\d+)/)[1].to_i
        @tree_cause = err.cause.ascii_tree
      end
      attr_reader :line
      attr_reader :char
      attr_reader :tree_cause
    end

    class TransformError < CompileError
      def initialize(hash)
        @message = "Could not transform"
        if hash.is_a? Hash
          @source_hash = hash
          @line, @char = hash.values.keep_if{|x| x.is_a? Parslet::Slice}
            .first.line_and_column
        end
      end

      attr_reader :source_hash, :message
    end
  end
end

require_relative './compiler/parser'
require_relative './compiler/transform'
