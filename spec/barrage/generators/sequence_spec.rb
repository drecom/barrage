require 'spec_helper'
require 'barrage/generators/sequence'

describe Barrage::Generators::Sequence do
  context "When initialized" do
    subject { described_class.new(options) }

    context "with empty hash" do
      let(:options) { {} }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context "with required options" do
      let(:options) { {"length" => 16 } }

      it { is_expected.to be_instance_of(Barrage::Generators::Sequence) }
      its(:length) { is_expected.to eq(options["length"]) }
    end
  end

  describe "#generate" do
    subject { described_class.new(options).generate }
    let(:length) { 9 }
    let(:options) { {"length" => length } }

    it { is_expected.to be_instance_of(Fixnum) }
    it { is_expected.to be < 2 ** length }

    context "When sequence is 0" do
      before do
        subject.instance_variable_set(:@sequence, 0)
      end
      subject { described_class.new(options) }

      it "should generates '1'" do
        expect(subject.generate).to eq(1)
      end

      it "if generate twice in a row, generated numbers should be in succession" do
        first = subject.generate
        second = subject.generate
        expect(first.succ).to eq(second)
      end
    end

    context "When sequence is max" do
      before do
        subject.instance_variable_set(:@sequence, (2 ** length) - 1)
      end
      subject { described_class.new(options) }

      it "should generates zero" do
        expect(subject.generate).to be_zero
      end
    end
  end
end
