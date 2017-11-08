require 'spec_helper'

RSpec.describe FifthedSim::Stat do
  context "with a block definition" do
    subject do
      described_class.define do
        value 10
        save_mod_bonus 3
      end
    end

    it  do
      is_expected.to have_attributes(value: 10,
                                     mod: 0,
                                     save_mod_bonus: 3)
    end

    describe ".saving_throw" do
      let(:roll) { subject.saving_throw }

      it "has an average of 13.5" do
        expect(roll.average).to be_within(0.000001).of(13.5)
      end
    end
  end

  context "with a dictionary definition" do
    let(:attributes) do
      {
        value: 20,
        mod_bonus: 2,
        save_mod_bonus: 10
      }
    end

    subject do
      described_class.new(attributes)
    end

    it "works" do
      expect{subject}.to_not raise_error
    end

    it { is_expected.to have_attributes(attributes) }
  end
end
