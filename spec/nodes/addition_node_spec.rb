require 'spec_helper'
require "shared_examples/dice_expression"

RSpec.describe FifthedSim::AdditionNode do

  context "with an example node" do
    let(:node) { 1.d(20) + 2 }
    include_examples "dice expression"
  end

  %w(1 10 20).each do |v|
    let("d20_#{v}".to_sym) do
      FifthedSim::RollNode.new(v.to_i, 20)
    end

    let("d20_#{v}_r".to_sym) do
      FifthedSim::MultiNode.new([self.send("d20_#{v}".to_sym)])
    end
  end

  %w(1 3 6).each do |v|
    let("d6_#{v}".to_sym) do
      FifthedSim::RollNode.new(v.to_i, 6)
    end

    let("d6_#{v}_r".to_sym) do
      FifthedSim::MultiNode.new([self.send("d20_#{v}".to_sym)])
    end
  end

  context "with a crit d20, a critfail d20, and a 5 modifier" do
    subject do
      described_class.new(d20_1_r, d20_20_r) + 5
    end
    it { is_expected.to_not be_above_average }
    it { is_expected.to be_average }
    it { is_expected.to_not be_below_average }

    it "should have a value of 26" do
      expect(subject.value).to eq(26)
    end

    it "should have an average value of 26" do
      expect(subject.average).to be_within(0.0002).of(26)
    end
  end

  context "with a crit d20, a critfail d6, and a 2 modifier" do
    subject do
      described_class.new(d20_20_r, d6_1_r) + 2
    end
    it "should have a value of 23" do
      expect(subject.value).to eq(23)
    end

    it "creates a distribution" do
      expect{subject.distribution}.to_not raise_error
    end
  end
end
