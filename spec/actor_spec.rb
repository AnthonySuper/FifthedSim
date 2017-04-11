require 'spec_helper'

RSpec.describe FifthedSim::Actor do
  context "with a semi-standard peasant" do
    subject do
      described_class.define "Peasant" do
        base_ac 10
        stats do
          str do
            value 10
          end
          dex do
            value 10
            mod_bonus 1
            save_mod_bonus 2
          end
          wis do
            value 10
          end
          cha do 
            value 10
          end
          con do
            value 10
          end
          int do
            value 10
          end
        end
        attack "club" do
          to_hit 2
          damage do
            bludgeoning 1.d(4)
          end
        end
      end
    end
    it "works" do
      expect{subject}.to_not raise_error
    end
  end
end

