require 'barrage/generators'
require 'active_support/core_ext/class/attribute'

class Barrage
  module Generators
    class Base
      attr_reader :options
      class_attribute :required_options, :available_options
      self.required_options = %w(length)
      self.available_options = []

      def initialize(options = {})
        if (missing = missing_required_options(options)) && !missing.empty?
          raise ArgumentError, "Missing Required options: #{missing.join(', ')}"
        end
        @options = options
      end

      def length
        options["length"]
      end

      def generate
        raise NotImplemented, "Please Override"
      end

      def current
        raise NotImplemented, "Please Override"
      end

      private

      def missing_required_options(given_options)
        required_options.reject { |k| given_options.has_key?(k) }
      end
    end
  end
end
