
require 'benchmark/ips'

module Wrap
  def wrap(name)
    orig = instance_method(name)

    define_method(name) do
      orig.bind(self).()
    end
  end

  def amc(name)
    orig_name = :"orig_#{name}"
    alias_method orig_name, name

    define_method(name) do
      send orig_name
    end
  end

  def amv_eval(name)
    orig_name = :"orig_#{name}"
    alias_method orig_name, name

    instance_eval <<-CODE
    def #{name}
      #{orig_name}
    end
    CODE
  end
end

class Foo
  extend Wrap

  def original_method
    2
  end

  def method_to_override
    2
  end
  wrap :method_to_override

  def amc_method
    2
  end
  amc :amc_method

  def amc_eval_method
    2
  end
  amc :amc_eval_method
end

FOO = Foo.new

Benchmark.ips do |x|

  x.report "plain method" do
    FOO.original_method
  end

  x.report "wrapped method" do
    FOO.method_to_override
  end

  x.report "alias_method_chain define_method method" do
    FOO.amc_method
  end

  x.report "alias_method_chain eval method" do
    FOO.amc_eval_method
  end
end

