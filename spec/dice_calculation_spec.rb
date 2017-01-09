require 'spec_helper'

RSpec.describe FifthedSim::DiceCalculation do
  describe "initialization" do
    it "fails with non-member types" do
      expect{described_class.new("")}.to raise_error(TypeError)
    end
  end

  %w(1 10 20).each do |v|
    let("d20_#{v}".to_sym) do
      FifthedSim::DieRoll.new(v.to_i, 20)
    end

    let("d20_#{v}_r".to_sym) do
      FifthedSim::DiceResult.new([self.send("d20_#{v}".to_sym)])
    end
  end

  context "with a crit d20, a critfail d20, and a 5 modifier" do
    subject do
      described_class.new(d20_1_r, d20_20_r, 5)
    end
    it { is_expected.to have_critfail }
    it { is_expected.to have_crit }
    it { is_expected.to_not be_above_average }
    it { is_expected.to be_average }
    it { is_expected.to_not be_below_average }

    it "should have a value of 26" do
      expect(subject.value).to eq(26)
    end

    it "should have an average value of 26" do
      expect(subject.average).to eq(26)
    end
  end
end
