
require 'rubygems'
require 'rbench'

require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => "benchmark.db"
)
ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS active_record_models")
ActiveRecord::Base.connection.execute("CREATE TABLE active_record_models (id INTEGER UNIQUE, title STRING, text STRING)")
class ActiveRecordModel < ActiveRecord::Base
end
# Have AR scan the table before the benchmark
ActiveRecordModel.new

class PlainModel
  attr_accessor :id, :title, :text

  def initialize(attrs = {})
    @id, @title, @text = attrs[:id], attrs[:title], attrs[:text]
  end

end

class HashModel
  def initialize(attributes = {})
    attrs = {}
    attrs.merge!(attributes)
  end
end

ATTRS = {:id => 1, :title => "Foo", :text => "Bar"}

RBench.run(100_000) do

  column :times
  column :plain,       :title => "Class"
  column :hash,        :title => "Hash"
  column :ar,          :title => "AR #{ActiveRecord::VERSION::STRING}"

  report ".new()" do
    plain do
      PlainModel.new
    end
    hash do
      Hash.new
    end
    ar do
      ActiveRecordModel.new
    end
  end

  report ".new(#{ATTRS.inspect})" do
    plain do
      PlainModel.new ATTRS
    end
    hash do
      Hash.new ATTRS
    end
    ar do
      ActiveRecordModel.new ATTRS
    end
  end


end
