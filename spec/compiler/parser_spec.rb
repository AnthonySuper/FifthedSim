require "spec_helper"
require "parslet/rig/rspec"

RSpec.describe FifthedSim::Compiler::Parser do
  let(:parser) { described_class.new }

  describe ".space" do
    subject { parser.space }
    it { is_expected.to parse(" ") }
    it { is_expected.to parse("\t") }
    it { is_expected.to parse("\n") }
  end

  describe ".space?" do
    subject { parser.space? }
    it { is_expected.to parse(" ") }
    it { is_expected.to parse("") }
  end

  describe ".number" do
    subject { parser.number }
    it { is_expected.to parse("1") }
    it { is_expected.to parse("123123123") }
  end

  describe ".dice" do
    subject { parser.dice }
    it { is_expected.to parse("1d20") }
    it { is_expected.to parse("d20") }
    it { is_expected.to_not parse("1d") }
  end

  describe ".add_op" do
    subject { parser.add_op }
    it { is_expected.to parse("+") }
    it { is_expected.to parse("-") }
    it { is_expected.to_not parse("+-") }
  end

  describe ".mult_op" do 
    subject { parser.mult_op }
    it { is_expected.to parse("*") }
    it { is_expected.to parse("/") }
    it { is_expected.to_not parse("*/") }
  end

  describe ".ident" do
    subject { parser.ident }
    it { is_expected.to parse("wow") }
    it { is_expected.to parse("foo") }
    it { is_expected.to_not parse("1d20") }
    it { is_expected.to_not parse("d20") }
  end

  describe ".arglist" do
    subject { parser.arglist }
    it { is_expected.to parse("1d20") }
    it { is_expected.to parse("1d20, 1d20") }
    it { is_expected.to_not parse("1d20 1d20") }
  end

  describe ".addition" do
    subject { parser.addition }
    it { is_expected.to parse("1d20 + 1d20") }
    it { is_expected.to parse("1d20 + 1d20*3") }
    it { is_expected.to parse("1d4 + 2") }
    it { is_expected.to parse("1d20*3 + 1d20") }
    it { is_expected.to parse("wow(1) + 1d20") }
    it { is_expected.to parse("1d20 + wow(1)") }
  end

  describe ".multiplication" do
    subject { parser.multiplication }
    it { is_expected.to parse("1d20 * 1d20") }
    it { is_expected.to parse("1d20 * 4") }
    it { is_expected.to parse("1d20*3") }
    
    it { is_expected.to parse("fun(1d20, 1d20) * 1d4") }
  end

  describe ".funcall" do
    subject { parser.funcall }
    it { is_expected.to parse("wow(1, 1)") }
    it { is_expected.to parse("foo(1d20, 1d20)") }
  end
  ["1d20 * 3 - 3d4",
   "1d20 * fun(10)",
   "1d20 + 3 - 4/1d4",
    "d4 + d4 + d4 + d4"].each do |expr|
     it { is_expected.to parse(expr) }
   end
end
