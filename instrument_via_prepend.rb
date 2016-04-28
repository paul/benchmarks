
require 'benchmark/ips'

module Instrumenter
  def instrument(name, &code)
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = yield
    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
    result
  end
end

module InstrumentViaDefineMethod
  module ClassMethods
    def instrument(method_name)
      prepend(Module.new do
        define_method method_name do |*a,&b|
          instrument(method_name) { super(*a, &b) }
        end
      end)
      method_name
    end
  end

  def self.included(mod)
    mod.extend ClassMethods
  end
end

module InstrumentViaEval
  module ClassMethods
    def instrument(method_name)
      instance_eval <<-CODE
        def #{method_name}(*a,&b)
          instrument(#{method_name.inspect}) do
            super
          end
        end
      CODE
      method_name
    end
  end

  def self.included(mod)
    mod.extend ClassMethods
  end
end

class FooPlain
  include Instrumenter
  def foo
    "a" * 1024**2
  end
end

class FooInline
  include Instrumenter
  def foo
    instrument "foo" do
      "a" * 1024**2
    end
  end
end

class FooPrependDefineMethod
  include Instrumenter
  include InstrumentViaDefineMethod

  def foo
    "a" * 1024**2
  end
  instrument :foo
end

class FooPrependEval
  include Instrumenter
  include InstrumentViaEval

  def foo
    "a" * 1024**2
  end
  instrument :foo

end

FOO_PLAIN  = FooPlain.new
FOO_INLINE = FooInline.new
FOO_PREPEND_DEF_METHOD = FooPrependDefineMethod.new
FOO_PREPEND_EVAL = FooPrependEval.new

Benchmark.ips do |x|

  x.report "none" do
    FOO_PLAIN.foo
  end

  x.report "in-line" do
    FOO_INLINE.foo
  end

  x.report "prepended w/ define_method" do
    FOO_PREPEND_DEF_METHOD.foo
  end

  x.report "prepended w/ eval" do
    FOO_PREPEND_EVAL.foo
  end

end
