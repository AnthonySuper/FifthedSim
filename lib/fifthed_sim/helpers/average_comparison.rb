module FifthedSim
  ##
  # A module containing methods for compairing a given result to the average result.
  # We do this in quite a few classes, so it's nice to have.
  #
  # Needs only the methods `.average` and `.value` to work.
  module AverageComparison
    ##
    # :method: above_average?
    # Check if this result is higher than the average result
    

    ##
    # :method: below_average?
    # Check if this result is lower than the average result
    
    ##
    # :method: average?
    # Check if this result is equal to the average result

    {"above_" => :>, "below_" => :<, "" => :==}.each do |k,v|
      define_method "#{k}average?" do
        value.public_send(v, average)
      end
    end

    ##
    # Get this difference of the average value and the current value.
    # For example, if the average is 10 and we have a value of 20, it will return 10.
    # Meanwhile, if the average is 10 and we have a value of 2, it will return -8.
    def difference_from_average
      value - average
    end
  end
end
