require 'spec_helper'

RSpec.describe FifthedSim::Damage do
  class FireIceMonster
    def resistant_to?(arg)
      arg == :fire
    end

    def immune_to?(arg)
      (arg == :cold).tap{|x| "FIM immune to #{arg}? #{x}"}
    end
  end
  let(:fireice) { FireIceMonster.new }

  class Normal
    def resistant_to?(_); false; end;
    def immune_to?(_); false; end;
  end
  let(:normal) { Normal.new }

  context "doing slashing damage" do
    subject do
      described_class.define do
        slashing 1.d(4)
      end
    end
    it "works" do
      expect{subject}.to_not raise_error
    end

    context "against a FireIce" do
      let(:foe) { fireice }
      it "does full damage" do
        expect(subject.to(foe).average).to eq(1.d(4).average)
      end
    end

    context "against a Normal" do
      let(:foe) { normal }
      it "does full damage" do
        expect(subject.to(foe).average).to be_within(0.0001).of(1.d(4).average)
      end
    end
  end

  context "doing fire and ice damage" do
    subject do
      described_class.define do
        cold 1.d(4)
        fire 1.d(4)
      end
    end

    context "against a FireIce" do
      let(:foe) { fireice }
      it "does half of 1d4" do
        expect(subject.to(foe).average).to eq((1.d(4) / 2).average)
      end
    end

    context "against a Normal" do
      let(:foe) { normal } 
      it "does full damage" do
        expect(subject.to(foe).average).to eq(2.d(4).average)
      end
    end
  end
end
