module FifthedSim
  module AverageComparison
    # metaprogramming lolz
    {"above_" => :>, "below_" => :<, "" => :==}.each do |k,v|
      define_method "#{k}average?" do
        value.public_send(v, average)
      end
    end

    def difference_from_average
      value - average
    end
  end
end
