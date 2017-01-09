RSpec.describe FifthedSim::DieRoll do
  describe "#roll" do
    it "fails when given a float" do
      expect{subject.roll(1.1)}.to raise_error(ArgumentError)
    end
  end

  describe "#average" do
    it "gives an average value" do
      expect(FifthedSim::DieRoll.average(20).value).to eq(10)
    end
  end

  context "with critfails" do
    subject { FifthedSim::DieRoll.new(1, 20) }
    it { is_expected.to be_critfail }
    it { is_expected.to_not be_crit }
    it { is_expected.to be_below_average }
    it { is_expected.to_not be_above_average }
    it { is_expected.to_not be_average }

    it "converts to a 1" do
      expect(subject.to_i).to eq(1)
    end

    it "converst to 1.0" do
      expect(subject.to_f).to eq(1.0)
    end
  end

  context "with crits" do
    subject { FifthedSim::DieRoll.new(20, 20) }
    it { is_expected.to be_crit }
    it { is_expected.to_not be_critfail }
    it { is_expected.to_not be_below_average } 
    it { is_expected.to be_above_average }
    it { is_expected.to_not be_average } 

    it "converts to a 20" do
      expect(subject.to_i).to eq(20)
    end

    it "converts to a 20.0" do
      expect(subject.to_f).to eq(20.0)
    end
  end


end
