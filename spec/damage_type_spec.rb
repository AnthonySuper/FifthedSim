require 'spec_helper'

RSpec.describe FifthedSim::DamageTypes do
  describe "string conversion" do
    subject do
      described_class.convert("slashing")
    end
    it "does not raise an error" do
      expect{subject}.to_not raise_error
    end

    it "converts to a symbol" do
      expect(subject).to be_a(Symbol)
    end
  end
  let(:err) { described_class.const_get(:InvalidDamageType) }
  it "rejects invalid symbols" do
    expect{described_class.convert(:asdfasdf)}.to raise_error(err)
  end

  it "rejects invalid classes" do
    expect{described_class.convert(10)}.to raise_error(ArgumentError)
  end
end
