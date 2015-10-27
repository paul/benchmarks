
require 'rubygems'
require 'benchmark/ips'

require "forwardable"


class Caller
  extend Forwardable

  def def_method
    reciever.useful_method
  end

  define_method(:defined_method) { reciever.send(:useful_method) }

  class_eval <<-RUBY, __FILE__, __LINE__
    def eval_method
      reciever.useful_method
    end
  RUBY

  delegate [ :useful_method ] => :reciever

  def reciever
    @reciever ||= Receiver.new(true)
  end
end

class Receiver < Struct.new(:useful_method)

end

FOO = Caller.new

Benchmark.ips do |x|
  x.report("Calling directly")               { FOO.def_method }
  x.report("Calling by #define_method")      { FOO.defined_method }
  x.report("Calling by class_eval'd method") { FOO.eval_method }
  x.report("Calling by delegator")           { FOO.useful_method }
end

__END__

Calculating -------------------------------------
    Calling directly    76.124k i/100ms
Calling by #define_method
                        70.518k i/100ms
Calling by class_eval'd method
                        77.884k i/100ms
Calling by delegator    64.468k i/100ms
-------------------------------------------------
    Calling directly      3.373M (± 5.0%) i/s -     16.823M
Calling by #define_method
                          2.523M (± 6.2%) i/s -     12.623M
Calling by class_eval'd method
                          3.368M (± 6.1%) i/s -     16.823M
Calling by delegator      2.370M (± 4.9%) i/s -     11.862M
