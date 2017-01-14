require "spec_helper"

RSpec.describe FifthedSim::Spell do
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
  end
end
