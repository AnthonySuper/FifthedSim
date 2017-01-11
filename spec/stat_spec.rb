require 'spec_helper'

RSpec.describe FifthedSim::Stat do
  context "with a block definition" do
    subject do
      described_class.define do
        value 10
        save_mod 3
      end
    end

    it  do
      is_expected.to have_attributes(value: 10,
                                     mod: 0,
                                     save_mod: 3)
    end

    describe ".saving_throw" do
      let(:roll) { subject.saving_throw }
      it "has an average of 13.5" do
        expect(roll.average).to eq(13.5)
      end
    end
  end
end
