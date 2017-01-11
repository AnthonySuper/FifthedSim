require 'spec_helper'

RSpec.describe FifthedSim::GreaterNode do
  context "with a critfail d2 and a crit d2" do
    let(:node) do
      described_class.new(FifthedSim.make_roll(2, 2), 
                          FifthedSim.make_roll(1, 2))
    end
    subject { node }

    it "has a value of 2" do
      expect(subject.value).to eq(2)
    end
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
end
