
require 'rubygems'
require 'benchmark/ips'

#require "jdbc-sqlite3"
require "activerecord-jdbc-adapter"

require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "benchmark.db"
)
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_record_simple_models")
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_record_complex_models")
ActiveRecord::Base.connection.execute("CREATE TABLE active_record_simple_models (id INTEGER UNIQUE, title STRING, text STRING)")
ActiveRecord::Base.connection.execute("CREATE TABLE active_record_complex_models (id INTEGER UNIQUE, title STRING, text STRING, post_id STRING, newsroom_id STRING, timestamp TIMESTAMP, stats STRING)")

class ActiveRecordSimpleModel < ActiveRecord::Base; end
class ActiveRecordComplexModel < ActiveRecord::Base; end

# Have AR scan the table before the benchmark
ActiveRecordSimpleModel.new
ActiveRecordComplexModel.new


class SimplePlainModel
  attr_accessor :id, :title, :text

  def initialize(attrs = {})
    @id, @title, @text = attrs[:id], attrs[:title], attrs[:text]
  end

end

class ComplexPlainModel
  attr_accessor :id, :title, :text, :post_id, :newsroom_id, :timestamp, :stats

  def initialize(attrs = {})
    @id, @title, @text, @post_id, @newsroom_id, @timestamp, @stats = *attrs.values
  end

end

require "virtus"

class SimpleVirtusModel
  include Virtus.model

  attribute :id,    Integer
  attribute :title, String
  attribute :text,  String
end

class ComplexVirtusModel
  include Virtus.model

  attribute :id,          Integer
  attribute :title,       String
  attribute :text,        String
  attribute :post_id,     String
  attribute :newsroom_id, String
  attribute :timestamp,   String
  attribute :stats,       Hash
end

ATTRS = {:id => 1, :title => "Foo", :text => "Bar"}

COMPLEX_ATTRS = {
  id: 1, title: "Foo", text: "Bar",
  post_id: SecureRandom.uuid,
  newsroom_id: SecureRandom.uuid,
  timestamp: Time.now.iso8601,
  stats: {
    x: 1, y: 2, z: 3
  }
}

puts "Empty init"
Benchmark.ips do |x|

  x.report("plain")  { SimplePlainModel.new        }
  x.report("Hash")   { Hash.new              }
  x.report("AR")     { ActiveRecordSimpleModel.new }
  x.report("Virtus") { SimpleVirtusModel.new       }
end

puts "init w/ attrs"
Benchmark.ips do |x|

  x.report("plain")  { SimplePlainModel.new        ATTRS }
  x.report("Hash")   { Hash.new                    ATTRS }
  x.report("AR")     { ActiveRecordSimpleModel.new ATTRS }
  x.report("Virtus") { SimpleVirtusModel.new       ATTRS }
end

puts "init w/ complex modelx"
Benchmark.ips do |x|

  x.report("plain")  { ComplexPlainModel.new        COMPLEX_ATTRS }
  x.report("Hash")   { Hash.new                     COMPLEX_ATTRS }
  x.report("AR")     { ActiveRecordComplexModel.new COMPLEX_ATTRS }
  x.report("Virtus") { ComplexVirtusModel.new       COMPLEX_ATTRS }
end

__END__

Empty init
Calculating -------------------------------------
               plain    24.748k i/100ms
                Hash    26.678k i/100ms
                  AR     5.042k i/100ms
              Virtus     2.437k i/100ms
-------------------------------------------------
               plain      1.604M (± 6.8%) i/s -      7.994M
                Hash      1.256M (± 9.9%) i/s -      6.243M
                  AR     71.964k (± 3.6%) i/s -    363.024k
              Virtus     28.120k (± 4.2%) i/s -    141.346k
init w/ attrs
Calculating -------------------------------------
               plain    24.792k i/100ms
                Hash    25.341k i/100ms
                  AR     1.008k i/100ms
              Virtus     4.052k i/100ms
-------------------------------------------------
               plain      1.603M (± 7.1%) i/s -      7.983M
                Hash      1.257M (± 9.6%) i/s -      6.234M
                  AR     12.356k (± 3.1%) i/s -     62.496k
              Virtus     53.527k (± 4.0%) i/s -    267.432k
init w/ complex modelx
Calculating -------------------------------------
               plain    18.118k i/100ms
                Hash    25.895k i/100ms
                  AR   436.000  i/100ms
              Virtus   734.000  i/100ms
-------------------------------------------------
               plain    525.416k (± 6.7%) i/s -      2.627M
                Hash      1.275M (±10.4%) i/s -      6.318M
                  AR      4.411k (± 4.6%) i/s -     22.236k
              Virtus      7.728k (± 3.1%) i/s -     38.902k
