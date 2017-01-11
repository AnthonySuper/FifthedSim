require 'spec_helper'

RSpec.describe FifthedSim::StatBlock do
  context "with a valid defintion" do
    subject do
      described_class.define do
        str do
          value 10
        end
        dex do
          value 18
          save_mod 6
        end
        con do
          value 14
        end
        cha do
          value 16
        end
        int do
          value 14
          mod_bonus 1
        end
        wis do 
          value 8
        end
      end
    end

    it "is valid" do
      expect{subject}.to_not raise_error
    end
  end
end
