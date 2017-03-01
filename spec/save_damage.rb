require "spec_helper"

RSpec.describe FifthedSim::SaveDamag do
  context "save or do nothing" do
    subject do
      described_class.define("thunderhand") do
        damage do
          thunder 3.d(6)
        end

        save_damage do
        end
        save_dc 18
        save_type :wis
      end
    end
    it "works" do
      expect{subject}.to_not raise_error
    end

    context "against a monster with a save mod of 18" do
      it "does nothing" do
        d = double
        allow(d).to receive(:saving_throw).and_return(1.d(20) + 18)
        expect(subject.against(d).average).to eq(0)
      end
    end

    context "against a monster with a save mod of 0" do
      it "has a 3/20 chance of doing nothing" do
        d = double
        allow(d).to receive(:saving_throw).and_return(1.d(20))
        allow(d).to receive(:immune_to?).and_return(false)
        allow(d).to receive(:resistant_to?).and_return(false)
        l = subject.against(d).distribution.percent_exactly(0)
        expect(l).to be_within(0.0001).of(3.0 / 20.0)
      end
    end
  end
end
