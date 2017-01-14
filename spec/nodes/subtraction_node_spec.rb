require "spec_helper"
require "shared_examples/dice_expression"

RSpec.describe FifthedSim::SubtractionNode do
  context "Crit d20 - 1" do
    subject { FifthedSim::RollNode.new(1, 20) - 1 }
    let(:node) { subject }
    it_behaves_like "dice expression"
  end
end
