module Helpers
  module Serialization
    def serial_roundtrip(obj)
      FifthedSim.deserialize(FifthedSim.serialize(obj))
    end
  end
end
