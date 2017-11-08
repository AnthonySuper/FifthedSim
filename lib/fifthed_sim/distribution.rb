require 'set'

module FifthedSim
  ##
  # Models a probabilistic distribution.
  class Distribution

    class Coefficient
      ##
      # @param map a hash of result => chance
      # @param min the minimum value in the map (to save on calculation time)
      # @param max the maximum value in the map (also to save on calculation time)
      def initialize(map, min = nil, max = nil)
        # We want to properly find the max and min values
        # This is because out-of-range values after adding will be a bit "weird"
        # in the sense that they'll be *extremely close* to zero but not quite.
        # So we can use this information to later make them actually zero.
        @min = min || map.keys.min
        @max = max || map.keys.max
        # Round array up to nearest power of two
        # This is required for a proper FFT, typically.
        length = nearest_two_power(@max)
        # Actually convert to coefficient form
        @coeffs = 0.upto(length).map{|x| map[x] || 0.0}
      end

      # Let others read our attributes
      attr_reader :min, :max, :coeffs

      def add(other)
        # We add zero coefficients so the FFT can find more solutions.
        # Since the output polynomial is larger than the input 
        # polynomial (since it has more terms),
        # We need to padd this now.
        # Get the size to pad to here: 
        new_size = nearest_two_power(coeffs.size + other.coeffs.size)
        # Now pad our coefficients
        arr = extend_array(new_size)
        # And padd theirs
        oarr = other.extend_array(new_size)
        # Do the FFT
        fft = fft_recurse(arr)
        # And again
        offt = fft_recurse(oarr)
        # Pointwise-multiply
        mult = fft.zip(offt).map{|(a, b)| a * b}
        # Inverse FFT returns complex numbers again.
        # However, we only care about real probability,
        # so we just throw away the complex component.
        # Simple!
        res = inverse_fft(mult).map!(&:real)
        # now, just return a distribution:
        hsh = Hash[(min + other.min).upto(max + other.max).map do |x|
          [x, res[x]]
        end]
        Distribution.new(hsh)
      end

      def exp(pow)
        new_size = nearest_two_power(@max * (pow + 1))
        new_min = min*pow
        new_max = max*pow
        arr = extend_array(new_size)
        fft = fft_recurse(arr)
        fft.map!{|x| x**pow}
        res = inverse_fft(fft).map!(&:real)
        hsh = Hash[new_min.upto(new_max).map do |x|
          [x, res[x]]
        end]
        Distribution.new(hsh)
      end

      # Padd the array to a given size by adding 0 coefficients
      def extend_array(size)
        return Array.new(size) do |x|
          @coeffs[x] || 0.0
        end
        # return @coeffs + Array.new(size - @coeffs.size, 0.0)
      end

      private

      # FFT works best on powers of two.
      # In fact, ours only works on powers of two.
      # So we find the nearest power of two fairly often
      def nearest_two_power(num)
        return 1 if num == 0
        exp = Math.log(num, 2).ceil
        if exp == 0
          1
        else
          2**exp
        end
      end

      # The actual FFT. Borrowed from Rosetta Code.
      def fft_recurse(vec)
        # Base case: the FFT of a coefficient vector of size one is just the vector
        return vec if vec.size <= 1
        # The FFT works by splitting the coefficient vectors into odd and even indexes
        # We do that here
        evens_odds = vec.partition.with_index{|_,i| i.even?}
        # Now we smartly perform the FFT on both sides
        evens, odds = evens_odds.map{|even_odd| fft_recurse(even_odd)*2}
        # And zip them together while applying the solution
        evens.zip(odds).map.with_index do |(even, odd),i|
          even + odd * Math::E ** Complex(0, -2 * Math::PI * i / vec.size)
        end
      end

      # Due to more math trickery, we actually just another FFT
      # In order to invert the FFT
      def inverse_fft(vec)
        # The conjugate of a complex number works like this:
        #   a + bi => b + ai
        # This is the modification we perform to invert
        # the FFT
        nv = vec.map(&:conjugate)
        # Do the actual FFT
        applied = fft_recurse(nv)
        # Now we re-conjugate
        # The inverse FFT actually multiplies each coefficient by the number
        # of coefficients, so we divide that out here to be accurate.
        applied.map!(&:conjugate)
          .map!{|x| x / applied.size}
      end
    end
    ##
    # Get a distrubtion for a number.
    # This will be a uniform distribution with P = 1 at this number and P = 0 elsewhere.
    def self.for_number(num)
      self.new({num => 1.0})
    end

    def self.for_range(rng)
      size = rng.size.to_f
      e = 1.0 / size
      self.new(Hash[rng.map{|x| [x, e]}])
    end

    def self.for(obj)
      case obj
      when Fixnum
        self.for_number(obj)
      when Range
        self.for_range(obj)
      else
        raise ArgumentError, "can't amke a distribution for that"
      end
    end

    ##
    # We initialize class with a map of results to occurences, and a total number of possible different occurences.
    # Generally, you will not ever initialize this yourself.
    def initialize(map)
      keys = map.keys
      @max = keys.max
      @min = keys.min
      @map = map.dup
      @map.default = 0
      @coefficient = Coefficient.new(@map, @min, @max)
    end

    attr_reader :total_possible,
      :min,
      :max,
      :coefficient


    def range
      (@min..@max)
    end

    def map
      @map.dup
    end

    def average
      map.map{|k, v| k * v}.inject(:+)
    end

    ##
    # Obtain a new distribution of values.
    # When block.call(value) for this distribution is true, we will allow
    # values from the second distribution.
    # Otherwise, the value will be zero.
    #
    # This is mostly used in hit calculation - AKA, if we're higher than an AC, then we hit, otherwise we do zero damage
    def hit_when(other, &block)
      hit_prob = map.map do |k, v|
        if block.call(k)
          v
        else
          nil
        end
      end.compact.inject(:+)
      miss_prob = 1 - hit_prob
      omap = other.map
      h = Hash[omap.map{|k, v| [k, v * hit_prob]}]
      h[0] = (h[0] || 0) + miss_prob
      Distribution.new(h)
    end

    ##
    # Takes a block or callable object.
    # This function will call the callable with all possible outcomes of this distribution.
    # The callable should return another distribution, representing the possible values when this possibility happens.
    # This will then return a value of those possibilities.
    #
    # An example is probably helpful here.
    # Let's consider the case where a monster with +0 to hit is attacking a creature with AC 16 for 1d4 damage, and crits on a 20.
    # If we want a distribution of possible outcomes of this attack, we can do:
    #
    #   1.d(20).distribution.results_when do |x|
    #     if x < 16
    #       Distribution.for_number(0)
    #     elseif x < 20
    #       1.d(4).distribution
    #     else
    #       2.d(4).distribution
    #     end
    #   end
    def results_when(&block)
      h = Hash.new{|h, k| h[k] = 0}
      range.each do |v|
        prob = @map[v]
        o_dist = block.call(v)
        o_dist.map.each do |k, v|
          h[k] += (v * prob)
        end
      end
      Distribution.new(h)
    end

    def percent_within(range)
      percent_where{|x| range.contains? x}
    end

    def percent_where(&block)
      @map.to_a
        .keep_if{|(k, v)| block.call(k)}
        .map{|(k, v)| v}
        .inject(:+)
    end

    def percent_exactly(num)
      return 0 if num < @min || num > @max
      @map[num] || 0
    end

    def variance
      avg = average
      @map.map do |k, v|
        ((k - avg)**2) * v
      end.inject(:+)
    end

    def std_dev
      Math.sqrt(variance)
    end

    def percent_lower(n)
      num = n - 1
      return 0.0 if num < @min
      return 1.0 if num > @max
      @min.upto(num).map(&self).inject(:+)
    end

    def percent_greater(n)
      num = n + 1
      return 0.0 if num > @max
      return 1.0 if num < @min
      num.upto(@max).map(&self).inject(:+)
    end

    def percent_lower_equal(num)
      percent_lower(num + 1)
    end

    def percent_greater_equal(num)
      percent_greater(num - 1)
    end

    alias_method :percentile_of,
      :percent_lower_equal

    def convolve(other)
      @coefficient.add(other.coefficient)
    end

    def power_convolve(pow)
      @coefficient.exp(pow)
    end

    ##
    # TODO: Optimize this
    def convolve_subtract(other)
      h = Hash.new{|h, k| h[k] = 0}
      range.each do |v1|
        other.range.each do |v2|
          h[v1 - v2] += percent_exactly(v1) * other.percent_exactly(v2)
        end
      end
      self.class.new(h)
    end

    ##
    # Get the distribution of a result from this distribution divided by
    # one from another distribution.
    # If the other distribution may contain zero this will break horribly.
    def convolve_divide(other)
      throw ArgumentError, "Divisor may be zero" if other.min < 1
      h = Hash.new{|h, k| h[k] = 0}
      # We can do this faster using a sieve, but be lazy for now
      # TODO: Be less lazy
      range.each do |v1|
        other.range.each do |v2|
          h[v1 / v2] += percent_exactly(v1) * other.percent_exactly(v2)
        end
      end
      self.class.new(h)
    end

    def convolve_multiply(other)
      h = Hash.new{|h, k| h[k] = 0}
      range.each do |v1|
        other.range.each do |v2|
          h[v1 * v2] += percent_exactly(v1) * other.percent_exactly(v2)
        end
      end
      self.class.new(h)
    end


    def convolve_greater(other)
      h = Hash.new{|h, k| h[k] = 0}
      # for each value
      range.each do |s|
        (s..other.max).each do |e|
          h[e] += (other.percent_exactly(e) * percent_exactly(s))
        end
        h[s] += (other.percent_lower(s) * percent_exactly(s))
      end
      self.class.new(h)
    end

    def convolve_least(other)
      h = Hash.new{|h, k| h[k] = 0}
      range.each do |s|
        (other.min..s).each do |e|
          h[e] += (other.percent_exactly(e) * percent_exactly(s))
        end
        h[s] += (other.percent_greater(s + 1) * percent_exactly(s))
      end
      self.class.new(h)
    end

    COMPARE_EPSILON = 0.00001
    def ==(other)
      omap = other.map
      max_possible = (@max / other.min)
      same_keys = (Set.new(@map.keys) == Set.new(omap.keys))
      same_vals = @map.keys.each do |k|
        (@map[k] - other.map[k]).abs <= COMPARE_EPSILON
      end
      same_keys && same_vals
    end

    def text_histogram(cols = 60)
      max_width = @max.to_s.length
      justwidth = max_width + 1
      linewidth = (cols - justwidth)
      range.map do |v|
        "#{v}:".rjust(justwidth) + ("*" * (percent_exactly(v) * linewidth))
      end.join("\n")
    end

    def to_proc
      Proc.new do |arg|
        @map[arg] || 0
      end
    end
  end
end
