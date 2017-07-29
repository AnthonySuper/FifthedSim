require 'spec_helper'

RSpec.describe FifthedSim::FifthSerial do
  subject { described_class }

  describe "atoms" do
    ["str", 1, 2.5].each do |val|
      it "recognizes a #{val.class}" do
        expect(subject.is_atom?(val)).to be true
      end
    end
  end

  describe "registration" do
    let(:klass) do 
      Class.new do 
        def self.from_fifth_serial hash
        end
      end
    end

    it "registers" do
      expect {
        subject.register(:foo, klass)
      }.to_not raise_error
    end

    it "requires a class" do
      expect { 
        subject.register(:foo, "string")
      }.to raise_error(FifthedSim::FifthSerial::RegistrationError)
    end
  end
end
