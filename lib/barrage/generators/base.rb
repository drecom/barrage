class Barrage
  module Generators
    class Base
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def length
        options["length"]
      end

      def generate
        raise NotImplemented, "Please Override"
      end
    end
  end
end
