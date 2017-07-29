$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fifthed_sim'
require_relative "./helpers/serialization"

RSpec.configure do |c|
  c.include Helpers::Serialization
end

