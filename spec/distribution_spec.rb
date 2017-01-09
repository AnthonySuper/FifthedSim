require "spec_helper"

RSpec.describe FifthedSim::Distribution do
  let(:two_d20) { FifthedSim::DiceResult.d(2, 20).distribution }
  context "with 2 d20s" do
    subject do
      two_d20
    end

    let(:unique_prob) { 1.0 / 20**2 }

    it "calculates the probability of critting" do
      expect(subject.percent_exactly(40)).to eq(unique_prob)
    end

    it "calculates the probability of critfailing" do
      expect(subject.percent_exactly(2)).to eq(unique_prob)
    end

    it "calculates values below the range" do
      expect(subject.percent_exactly(0)).to eq(0)
    end

    it "calculates values above the range" do
      expect(subject.percent_exactly(41)).to eq(0)
    end

    it "calculates values up to a certain value" do
      expect(subject.percent_least(39)).to eq(1.0 - unique_prob)
    end
  end

  describe "convolving a d20" do
    let(:d20) { FifthedSim::DiceResult.d(1, 20).distribution }
    context "with a d20" do
      subject do
        d20.convolve(d20)
      end

      it "has the right singular chance" do
        expect(subject.percent_exactly(40)).to eq(1.0 / (20 ** 2))
      end
      it { is_expected.to eq(two_d20) }
    end

    context "with the number 5" do
      subject { d20.convolve(described_class.for_number(5)) }
      it "has no chance of being 2" do
        expect(subject.percent_exactly(2)).to eq(0)
      end

      it "has a 1 in 20 chance of being a 6" do
        expect(subject.percent_exactly(6)).to eq(1.0 / 20)
      end
      
      it "uniformly has a chance of 1 in 20" do
        expect(subject.probability_map.values).to eq(20.times.map{1.0 / 20})
      end
    end
  end
end
