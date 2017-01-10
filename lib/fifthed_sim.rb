require "fifthed_sim/version"
require "fifthed_sim/dice_result"
require "fifthed_sim/die_roll"
require "fifthed_sim/dice_calculation"
require "fifthed_sim/distribution"
require "securerandom"

module FifthedSim

  ##
  # Roll a dice.
  # Normally, you access this through the monkey-patch on Fixnum.
  def self.d(*args)
    DiceResult.d(*args)
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
