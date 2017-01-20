require "fifthed_sim/version"
require "fifthed_sim/dice_expression"
require "fifthed_sim/distribution"
require "fifthed_sim/attack"
require "fifthed_sim/actor"
require "fifthed_sim/stat_block"
require "fifthed_sim/damage_types"
require "fifthed_sim/damage"
require "fifthed_sim/spell"
require "securerandom"

module FifthedSim

  ##
  # Roll a dice.
  # Normally, you access this through the monkey-patch on Fixnum.
  def self.d(*args)
    MultiNode.d(*args)
  end

  def self.make_roll(val, type)
    RollNode.new(val, type)
  end

  def self.define_actor(name, &block)
    Actor.define(name, &block)
  end
end

class Fixnum
  ##
  # Enable you to create dice rolls via `3.d(6)` syntax.
  # This returns a DiceResult, meaning that you can add them together
  # to form a calculation.
  def d(o)
    FifthedSim.d(self, o)
  end


end
