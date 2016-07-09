module Fintech
  module Rate
    class Simple
      def initialize(rate)
        @rate = rate
      end

      def annual
        @rate
      end

      def daily
        @rate / 365
      end

      def monthly
        @rate / 12
      end
    end
  end
end
