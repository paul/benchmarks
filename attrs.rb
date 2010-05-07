
require 'rubygems'
require 'rbench'

TIMES = 1_000_000

class Attrs
  attr_accessor :foo, :bar, :baz
end
ATTRS = Attrs.new

require 'fattr'
class Fattrs
  fattr :foo, :bar, :baz
end
FATTERS = Fattrs.new

class Methods
  def foo
    @foo
  end
  def foo=(val)
    @foo = val
  end
end
METHODS = Methods.new


RBench.run(TIMES) do
  column :attrs
  column :fatters
  column :methods

  report "Init" do
    attrs   { Attrs.new }
    fatters { Fattrs.new }
    methods { Methods.new }
  end

  report "Getter" do
    attrs   { ATTRS.foo }
    fatters { FATTERS.foo }
    methods { METHODS.foo }
  end

  report "Setter" do
    attrs   { ATTRS.foo=(:bar) }
    fatters { FATTERS.foo=(:bar) }
    methods { METHODS.foo=(:bar) }
  end

end

