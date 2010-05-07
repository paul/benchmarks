
require 'rubygems'
require 'rbench'

FooBar = "foobar"

RBench.run(10_000_000) do
  column :literal
  column :symbol
  column :constant

  report "init" do
    literal  { "foobar" }
    symbol   { :foobar }
    constant { FooBar }
  end
end

