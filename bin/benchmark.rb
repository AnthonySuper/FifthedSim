$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "../lib"))
require 'fifthed_sim'
require 'benchmark'
Benchmark.bm(7) do |x|
  x.report("1d100") { 1000.times{ 1.d(100) } }
  x.report("10d100.distribution") { 2.times{ 10.d(100).distribution } }
end

