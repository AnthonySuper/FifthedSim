require "fifthed_sim/version"
require "fifthed_sim/dice_result"
require "fifthed_sim/die_roll"
require "fifthed_sim/dice_calculation"
require "fifthed_sim/distribution"
require "securerandom"

module FifthedSim
  def self.d(*args)
    DiceResult.d(*args)
  end
end

class Fixnum
  def d(o)
    FifthedSim.d(self, o)
  end
end
