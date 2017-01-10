require 'spec_helper'

RSpec.describe FifthedSim::Attack do
  describe "DSL construction" do
    subject do
      proc do
        described_class.define "Longsword" do
          modifier 5
          damage 2.d(6)
          crit_threshold 18
        end
      end
    end

    let(:attack) { subject.call }
    it "does not throw" do
      expect(&subject).to_not raise_error
    end

    it "calculates the right to hit" do
      expect(attack.to_hit.average).to eq((1.d(20) + 5).average)
    end

    it "calcultes the right damage" do
      expect(attack.damage.average).to eq((2.d(6).average))
    end
  end
end
