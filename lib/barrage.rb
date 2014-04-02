require "barrage/version"
require "active_support/core_ext/string/inflections"

class Barrage
  class InvalidOption < StandardError; end
  attr_reader :generators

  #
  # generators:
  #   - name: msec
  #     length: 40
  #     start_at: 1396439813232 # 2014-04-02 20:56:53 +0900
  #   - name: pid
  #     length: 16
  #   - name: sequence
  #     length: 8

  def initialize(options = {})
    @options = options
    @generators = @options["generators"].map do |h|
      generator_name = h["name"]
      require "barrage/generators/#{generator_name}"
      "Barrage::Generators::#{generator_name.classify}".constantize.new(h)
    end
  end

  def next
    generate
  end

  private

  def generate
    shift_size = length
    @generators.inject(0) do |result, generator|
      shift_size = shift_size - generator.length
      result += generator.generate << shift_size
    end
  end

  def length
    @generators.inject(0) {|sum, g| sum += g.length }
  end
end
