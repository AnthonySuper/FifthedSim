module FifthedSim
  module CalculatedFixnum
    refine Fixnum do
      def value
        self
      end

      def average
        self
      end

      def has_critfail?
        false
      end

      def has_crit?
        false
      end

      def distance_from_average
        0
      end

      def distribution
        FifthedSim::Distribution.for_number(self)
      end

      def average?
        true
      end

      def below_average?
        false
      end

      def above_average?
        false
      end

      def difference_from_average
        0
      end

      def reroll
        self
      end

      def value_equation(terminal: false)
        self.to_s
      end

      def expression_equation
        self.to_s
      end
    end
  end
end
