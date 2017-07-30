require 'spec_helper'

RSpec.describe FifthedSim::Attack do
  context "for a slashing longsword" do
    subject do
      described_class.define "Longsword" do
        to_hit 5
        damage do
          slashing 2.d(6)
        end
        crit_damage do
          slashing 4.d(6)
        end
        crit_threshold 18
      end
    end

    it "serializes properly" do
      rt = serial_roundtrip(subject)
      expect(rt.hit_roll.average).to eq(subject.hit_roll.average)
    end

    it "does not throw" do
      expect{subject}.to_not raise_error
    end

    it "calculates the right to hit" do
      expect(subject.hit_roll.average).to eq((1.d(20) + 5).average)
    end

    it "calcultes the right damage with no resistance" do
      expect(subject.raw_damage.average).to eq((2.d(6).average))
    end
  end
end
