require 'spec_helper'
require 'barrage/generators/redis_worker_id'

describe Barrage::Generators::RedisWorkerId do
  context "When initialized" do
    subject { described_class.new(options) }

    context "with empty hash" do
      let(:options) { {} }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context "with required options" do
      let(:options) { {"length" => 16, "ttl" => 300} }

      it { is_expected.to be_instance_of(Barrage::Generators::RedisWorkerId) }
      its(:length) { is_expected.to eq(options["length"]) }
      its(:ttl) { is_expected.to eq(options["ttl"]) }
    end
  end

  describe "#generate" do
    subject { described_class.new(options).generate }
    let(:length) { 8 }
    let(:ttl) { 300 }
    let(:options) { {"length" => length, "ttl" => ttl} }

    it { is_expected.to be_instance_of(Fixnum) }
    it { is_expected.to be < 2 ** length }

    context "on many instances" do
      subject { 64.times.map { described_class.new(options) } }
      let(:length) { 8 }

      it "should generate unique numbers" do
        numbers = subject.map(&:generate)
        expect(numbers.size).to eq(numbers.uniq.size)
      end

      it "generates numbers should less than length" do
        expect(subject.all? { |s| s.generate < (2 ** length) }).to be true
      end
    end
  end
end
