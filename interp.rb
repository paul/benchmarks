
require 'benchmark'

class Dummy

  attr_writer :setter

  def orig(att, value)
    send("#{att}=", value) if respond_to?("#{att}=")
  end

  def cache_name(att, value)
    method_name = "#{att}="
    send(method_name, value) if respond_to?(method_name)
  end

  def symbolize_method_name(att, value)
    method_name = :"#{att}="
    send(method_name, value) if respond_to?(method_name)
  end

  def no_iterp(att, value)
    method_name = (att.to_s + '=').to_sym
    send(method_name, value) if respond_to?(method_name)
  end
end

N = 1_000_000
@dummy = Dummy.new
Benchmark.bm do |x|
  x.report("orig") { N.times { @dummy.orig(:setter, 1) } }
  x.report("cache_name") { N.times { @dummy.cache_name(:setter, 1) } }
  x.report("symbolize_method_name") { N.times { @dummy.symbolize_method_name(:setter, 1) } }
  x.report("no_iterp") { N.times { @dummy.no_iterp(:setter, 1) } }
end

__END__

      user     system      total        real
orig  1.430000   0.000000   1.430000 (  1.423196)
cache_name  0.970000   0.000000   0.970000 (  0.970152)
symbolize_method_name  0.930000   0.000000   0.930000 (  0.937663)
no_iterp  0.830000   0.000000   0.830000 (  0.823327)
