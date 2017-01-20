require 'parslet'

class FifthedSim::Compiler
  class Transform < Parslet::Transform
    rule(:number => simple(:x)) { Integer(x) }
    rule(dice: {die_count: simple(:c), die_type: simple(:t)}) do
      if c
        c.d(t)
      else
        FifthedSim::RollNode.roll(t)
      end
    end
    rule(op: simple(:op), lhs: simple(:lhs), rhs: simple(:rhs)) do
      lhs.to_dice_expression.public_send(op, rhs.to_dice_expression)
    end
    FUNC_MAP = {
      "max" => :or_greater,
      "min" => :or_least
    }
    FUNC_MAP.each do |k, v|
      rule(ident: k, args: sequence(:args)) do |d|
        d[:args].inject do |mem, arg|
          mem.to_dice_expression.public_send(v, arg)
        end
      end
    end
  end
end
