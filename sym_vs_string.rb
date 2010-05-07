

require 'rubygems'
require 'rbench'

TIMES = 1_000

SYM = {:foo => "bar"}
STR = {"foo" => "bar"}

RBench.run(TIMES) do

  column :sym
  column :str

  report "hash lookup" do
    sym { SYM[:foo] }
    str { STR["foo"] }
  end
end
