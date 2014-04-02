require 'barrage/generators/base'

class Barrage
  module Generators
    class Pid < Base
      def generate
        Process.pid & (2 ** length-1)
      end
    end
  end
end
