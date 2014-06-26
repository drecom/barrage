require 'spec_helper'

describe Barrage do
  it 'has a version number' do
    expect(Barrage::VERSION).not_to be nil
  end

  context "when initialized" do
    subject { Barrage.new(options) }

    context "with empty generators" do
      let(:options) { {"generators" => []} }
      its(:generators) { is_expected.to be_empty }
    end

    context "with generators" do
      let(:options) {
        {
          "generators" => [
            {"name" => "msec", "length" => 39, "start_at" => 1396278000000},
            {"name" => "redis_worker_id", "length" => 16, "ttl" => 300},
            {"name" => "sequence", "length" => 9}
          ]
        }
      }
      it { expect(subject.generators.size).to eq(options["generators"].size) }
      its(:generators) {
        is_expected.to contain_exactly(
          be_kind_of(Barrage::Generators::Msec),
          be_kind_of(Barrage::Generators::RedisWorkerId),
          be_kind_of(Barrage::Generators::Sequence)
        )
      }

      describe "#generate" do
        let(:barrage) { described_class.new(options) }
        subject { barrage.generate }
        it { is_expected.to be_kind_of(Integer) }
        it { is_expected.to be < 2 ** barrage.length }
      end

      describe "#length" do
        subject { described_class.new(options).length }
        it { is_expected.to eq(options["generators"].map { |h| h["length"]}.inject(:+)) }
      end
    end
  end
end
