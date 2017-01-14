require 'spec_helper'

RSpec.shared_examples "dice expression" do
  describe ".max" do
    it "returns a fixnum" do
      expect(node.max).to be_a(Fixnum)
    end

    it "is not less than min" do
      expect(node.max).to_not be < node.min
    end

    it "works" do
      expect{node.max}.to_not raise_error
    end
  end

  describe ".min" do
    it "returns a fixnum" do
      expect(node.min).to be_a(Fixnum)
    end
    
    it "is not greater than max" do
      expect(node.min).to_not be > node.min
    end

    it "works" do
      expect{node.min}.to_not raise_error
    end
  end

  describe ".distribution" do
    it "works" do
      expect{node.distribution}.to_not raise_error
    end

    it "returns a distribution" do
      expect(node.distribution).to be_a(FifthedSim::Distribution)
    end
  end

  describe ".average" do
    it "works" do
      expect{node.average}.to_not raise_error
    end
    
    it "returns a number" do
      expect(node.average).to be_a(Numeric)
    end
  end

  describe ".reroll" do
    it "works" do
      expect{node.reroll}.to_not raise_error
    end

    it "returns a DiceExpression" do
      expect(node.reroll).to be_a(FifthedSim::DiceExpression)
    end
  end

  [:+, :-, :/, :*].each do |meth|

    describe ".#{meth}" do
      it "works" do
        expect{node.public_send(meth, 1.d(4))}.to_not raise_error
      end

      it "returns a DiceExpression" do
        expect(node.public_send(meth, 1.d(4))).to be_a(FifthedSim::DiceExpression)
      end
    end
  end
end
