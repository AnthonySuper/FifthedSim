require 'spec_helper'

RSpec.describe FifthedSim::GreaterNode do
  context "with a critfail d2 and a crit d2" do
    let(:node) do
      described_class.new(FifthedSim.make_roll(2, 2), 
                          FifthedSim.make_roll(1, 2))
    end
    subject { node }

    it { is_expected.to have_attributes(value: 2, min: 1, max: 2) }

    describe "distribution" do
      subject { node.distribution }
      it "has a 25% chance of being 1" do
        expect(subject.percent_exactly(1)).to be_within(0.001).of(0.25)
      end

      it "has a 75% chance of being a 2" do
        expect(subject.percent_exactly(2)).to be_within(0.001).of(0.75)
      end
    end
  end

  context "between 1d20 and 1d20 + 10" do
    let(:node) { 1.d(20).or_greater((1.d(20) + 10)) }
    subject { node }
    it { is_expected.to have_attributes(min: 11, max: 30) }

    describe ".distribution" do
      subject { node.distribution } 
      it "has a 0% chance of being 1" do
        expect(subject.percent_exactly(1)).to eq(0.0)
      end
    end
  end
end
