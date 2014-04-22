require 'barrage/generators/base'

class Barrage
  module Generators
    class Sequence < Base
      def initialize(options)
        @sequence = 0
        super
      end

      def generate
        @sequence = (@sequence + 1) & (2 ** length - 1)
      end

      def current
        @sequence
      end
    end
  end
end
