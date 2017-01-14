require 'spec_helper'
require "shared_examples/dice_expression"

RSpec.describe FifthedSim::BlockNode do
  context "Roll a d4, 0 on 1, 1d4 on 2..3, 1d4+4 on 4" do
    subject do
      1.d(4).test_then do |x|
        if x == 1
          0
        elsif x > 1 && x < 4
          1.d(4)
        else
          1.d(4) + 4
        end
      end
    end
    let(:node) { subject }
    it_behaves_like "dice expression"
    it { is_expected.to be_a(FifthedSim::DiceExpression) }
    it { is_expected.to respond_to(:distribution) }
    it { is_expected.to respond_to(:reroll) }
    it { is_expected.to respond_to(:value) }

    describe ".distribution" do
      it "has 25% chance of being zero" do
        percent = subject.distribution.percent_exactly(0)
        expect(percent).to be_within(0.001).of(0.25)
      end
    end
  end

  context "with a roll we know is 2" do
    subject do
      described_class.new(FifthedSim::RollNode.new(2, 2)) do |x|
        if x == 1
          0
        else
          2
        end
      end
    end
    let(:dist) { subject.distribution }
    it "should have a 50% chance of being 0" do
      expect(dist.percent_exactly(0)).to be_within(0.00001).of(0.5)
    end

    it "should have a 50% chance of being 2" do
      expect(dist.percent_exactly(2)).to be_within(0.00001).of(0.5)
    end

    it "should have an actual value of 2" do
      expect(subject.value).to eq(2)
    end
  end
end
