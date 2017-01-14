require 'spec_helper'

RSpec.describe FifthedSim::MultiNode do
  describe "initialization" do
    subject { described_class.method(:new) }

    it "requires an array" do
      expect { subject.call(1) }.to raise_error(ArgumentError)
    end

    it "requires an array with items" do
      expect { subject.call([]).to raise_error(ArgumentError) }
    end

    it "fails with an array of non-dierols" do
      expect { subject.call([10]) }.to raise_error(ArgumentError)
    end

    it "works with an array of dierolls" do
      expect do 
        subject.call([FifthedSim::RollNode.new(1, 20)]) 
      end.to_not raise_error
    end
  end

  describe "#d" do
    subject { described_class.method(:d) }

    it "rolls the right number of dice" do
      expect(subject.call(3, 6).roll_count).to eq(3)
    end

    it "requires the right type of rolls" do
      expect(subject.call(3, 6).average).to eq(3 * ((6 + 1) / 2.0))
    end
  end

  context "with a crit and an average roll" do
    subject do 
      described_class.new([FifthedSim.make_roll(20, 20),
                           FifthedSim.make_roll(10, 20)])
    end
    let(:node) { subject }
    it_behaves_like "dice expression"
    it { is_expected.to have_crit }
    it { is_expected.to_not have_critfail }
    it { is_expected.to be_above_average }
    it { is_expected.to_not be_below_average }
    it { is_expected.to_not be_average }

    it "is 10 away from average" do
      expect(subject.difference_from_average).to eq(9)
    end
  end

  context "with a critfail and an average roll" do
    subject do
      described_class.new([FifthedSim.make_roll(1, 20),
                           FifthedSim.make_roll(10, 20)])
    end

    it { is_expected.to_not have_crit }
    it { is_expected.to have_critfail }
    it { is_expected.to_not be_above_average }
    it { is_expected.to be_below_average }
    it { is_expected.to_not be_average }
    it "is -10 away from average" do
      expect(subject.difference_from_average).to eq(-10)
    end
  end

  context "one critfail and one crit" do
    subject do
      described_class.new([FifthedSim.make_roll(1, 20),
                           FifthedSim.make_roll(20, 20)])
    end
    it { is_expected.to have_crit }
    it { is_expected.to have_critfail }
    it { is_expected.to_not be_above_average }
    it { is_expected.to be_average }
    it { is_expected.to_not be_below_average }
  end

  describe "+" do
    subject do
      described_class.new([FifthedSim.make_roll(10, 20)]).method(:+)
    end

    it "returns a calculated value" do
      expect(subject.call(10)).to be_kind_of(FifthedSim::DiceExpression)
    end
  end

  describe "distribution" do
    subject{ described_class.d(2, 20).method(:distribution).to_proc }
    it "works" do
      expect(&subject).to_not raise_error
    end
  end
end
