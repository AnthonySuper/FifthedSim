require "spec_helper"
require "shared_examples/dice_expression"

RSpec.describe FifthedSim::SubtractionNode do
  context "Crit d20 - 1" do
    subject { FifthedSim::RollNode.new(1, 20) - 1 }
    let(:node) { subject }
    it_behaves_like "dice expression"
  end

  describe "serialization" do
    [FifthedSim::RollNode.new(1, 20) - 3, 
     FifthedSim::RollNode.new(1, 20) - 5].each do |expr|
      it "serializes #{expr} cleanly" do
        rt = serial_roundtrip(expr)
        expect(expr.value).to eq(expr.value)
        expect(expr.average).to eq(expr.average)
      end
    end
  end
end
