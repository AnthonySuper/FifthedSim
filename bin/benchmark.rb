$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "../lib"))
require 'fifthed_sim'
require 'benchmark'


def avg_benchmark(&block)
  1.upto(2).map do
    Benchmark.realtime(&block)
  end.inject(:+) / 2.0
end

1.upto(200).each do |n|
  d = avg_benchmark{
    n.d(10).distribution
  }
  puts "#{n}\t#{d}"
end
