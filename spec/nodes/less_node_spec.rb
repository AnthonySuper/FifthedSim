require 'spec_helper'

RSpec.describe FifthedSim::LessNode do
  context "with a critfail d2 and a crit d2" do
    subject do
      described_class.new(FifthedSim.make_roll(1, 2),
                          FifthedSim.make_roll(2, 2))
    end
    it { is_expected.to have_attributes(value: 1, min: 1, max: 2)}
  end

  context "with a d2 and a d20" do
    subject { 1.d(20).or_least(1.d(2)) }
    it { is_expected.to have_attributes(min: 1, max: 2, range: (1..2)) }
  end
end
