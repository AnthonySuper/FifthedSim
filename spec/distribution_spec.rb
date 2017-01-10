require "spec_helper"

RSpec.describe FifthedSim::Distribution do
  let(:two_d20) { FifthedSim::DiceResult.d(2, 20).distribution }
  let(:d4) { 1.d(4).distribution }

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
      p = 1.0 - unique_prob
      expect(subject.percent_least(39)).to be_within(0.0001).of(p)
    end
  end

  describe "convolving a d20" do
    let(:d20) { FifthedSim::DiceResult.d(1, 20).distribution }
    context "with a d20" do
      subject do
        d20.convolve(d20)
      end

      it "has the right singular chance" do
        p = (1.0 / (20 ** 2))
        expect(subject.percent_exactly(40)).to be_within(0.0001).of(p)
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
        expect(subject.map.values).to eq(20.times.map{1.0 / 20})
      end
    end

    context "with 2d6" do
      subject { d20.convolve(2.d(6).distribution) }
      it "has a correct probability for 3" do
        expect(subject.percent_exactly(3)).to be_within(0.0001).of(0.0014)
      end

      it "has a correct probability for 15" do
        expect(subject.percent_exactly(15)).to be_within(0.001).of(0.05)
      end
    end
  end

  describe "#hit_when" do
    context "d4, pass > 2, d4" do
      subject { d4.hit_when(d4){|x| x > 2} }
      it "should have a proper zero value" do
        expect(subject.percent_exactly(0)).to be_within(0.0001).of(0.5)
      end

      it "has proper non-zero values" do
        expect(subject.percent_where{|x| x > 0}).to be_within(0.0001).of(0.5)
      end
    end
  end
end
