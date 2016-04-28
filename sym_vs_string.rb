

require 'rubygems'
require 'benchmark/ips'


SYM = :foo
STR = "foo"

SYM_HASH = {:foo => "bar"}
STR_HASH = {"foo" => "bar"}

Benchmark.ips do |x|

  x.report("symbol #== SYM")     { SYM == SYM   }
  x.report("symbol #== :foo")    { SYM == :foo  }

  x.report("string #== STR")     { STR == STR   }
  x.report("string #== \"str\"") { STR == "foo" }

  x.report("symbol hash lookup") { SYM_HASH[SYM] }
  x.report("string hash lookup") { STR_HASH[STR] }

end
