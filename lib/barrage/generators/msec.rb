require 'barrage/generators/base'

class Barrage
  module Generators
    class Msec < Base
      self.required_options += %w(start_at)

      def generate
        ((Time.now.to_f * 500).round - start_at) & (2 ** length - 1)
      end

      alias_method :current, :generate

      def start_at
        options["start_at"]
      end
    end
  end
end
