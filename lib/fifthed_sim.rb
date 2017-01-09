require "fifthed_sim/version"
require "fifthed_sim/dice_result.rb"
require "fifthed_sim/die_roll.rb"
require "fifthed_sim/dice_calculation.rb"
require "fifthed_sim/distribution"

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
