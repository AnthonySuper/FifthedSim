require "spec_helper"
require "shared_examples/dice_expression"

RSpec.describe FifthedSim::MultiplicationNode do
  context "with a crit d20 and a 2" do
    let(:node) do
      described_class.new(FifthedSim::RollNode.new(20, 20), DiceExpression(2))
    end
    subject { node }
    it_behaves_like "dice expression"

    it "should be 40" do
      expect(subject.value).to eq(40)
    end
  end

  describe "serialization" do
    [1.d(20) * 2,
     1.d(10) * 1.d(10),
     (1.d(10) * 1.d(10)) * 1.d(20)].each do |expr|
       it "roundtrips #{expr}" do
         rt = serial_roundtrip(expr)
         expect(expr.value).to eq(rt.value)
         expect(expr.average).to eq(rt.average)
       end
     end
  end
end
