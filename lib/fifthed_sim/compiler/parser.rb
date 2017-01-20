require 'parslet'

class FifthedSim::Compiler 
  class Parser < Parslet::Parser
    root :addition
    rule(:space) { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:lparen) { str("(") >> space? }
    rule(:rparen) { str(")") >> space? }
    rule(:comma) { str(",") >> space? }
    rule(:number) { match('[0-9]').repeat(1).as(:number) }
    rule(:number?) { number.maybe }
    rule(:dice) do
      (number?.as(:die_count) >> str("d") >> number.as(:die_type) >> space?)
        .as(:dice)
    end
    rule(:base_term) { (dice | number) >> space? } 
    rule(:primary) { lparen >> addition >> rparen | base_term }

    rule(:add_op) { match('\+|-').as(:op) >> space? }
    rule(:addition) do
     (multiplication.as(:lhs) >> add_op >> addition.as(:rhs)) |
        multiplication
    end

    rule(:mult_op) { match('\*|/').as(:op) >> space? }

    rule(:multiplication) do 
      (mult_term.as(:lhs) >> (mult_op >> addition.as(:rhs))) |
        mult_term
    end

    rule(:mult_term) do
      primary | funcall
    end
    
    rule(:ident) { match('[a-zA-z]').repeat(1) }

    rule(:arglist) do
      addition >> (comma >> addition).repeat
    end

    rule(:funcall) { ident.as(:ident) >> lparen >> arglist.as(:args) >> rparen }
    rule(:expression) { funcall | multiplication | addition | base_term }
  end
end
