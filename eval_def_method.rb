
require 'rubygems'
require 'rbench'

TIMES = 1_000_000

class Foo
  def def_method
  end

  define_method(:defined_method) { }

  eval "def eval_method; end"
end

FOO = Foo.new

RBench.run(TIMES) do

  column :times
  column :def_method, :title => "def foo"
  column :defined_method, :title => "define_method(:foo)"
  column :evaled_method,   :title => "eval('def foo')"

  report "calling" do
    def_method do
      FOO.def_method
    end

    defined_method do
      FOO.defined_method
    end

    evaled_method do
      FOO.eval_method
    end
  end

end

