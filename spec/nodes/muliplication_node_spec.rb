require "spec_helper"
require "shared_examples/dice_expression"

RSpec.describe FifthedSim::MultiplicationNode do
  context "with a crit d20 and a 2" do
    let(:node) do
      described_class.new(FifthedSim::RollNode.new(20, 20), 2)
    end
    subject { node }
    it_behaves_like "dice expression"

    it "should be 40" do
      expect(subject.value).to eq(40)
    end
  end
end
