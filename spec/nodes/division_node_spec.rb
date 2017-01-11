require 'spec_helper'

RSpec.describe FifthedSim::DivisionNode do
  context "with a crit d2 and a 2" do
    let(:node) do
      described_class.new(FifthedSim::RollNode.new(2, 2), 2)
    end
    subject{ node }

    it "has a value of 1" do
      expect(subject.value).to eq(1)
    end

    describe "distribution" do
      subject { node.distribution }
      
      it "has a 50% chance of being 0" do
        expect(subject.percent_exactly(0)).to be_within(0.001).of(0.5)
      end

      it "has a 50% chance of being 1" do
        expect(subject.percent_exactly(1)).to be_within(0.001).of(0.5)
      end
    end
  end

  context "with 2ds" do
    subject do
      1.d(2) / 1.d(2)
    end

    it "has a max of 2" do
      expect(subject.max).to eq(2)
    end

    it "has a min of 0" do
      expect(subject.min).to eq(0)
    end
  end
end
