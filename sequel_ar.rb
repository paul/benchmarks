
require "active_record"

conn = {
  :adapter => "mysql",
  :database => "people_test",
  :socket => "/tmp/mysql.sock",
  :user => "root"
}

class ARPerson1 < ActiveRecord::Base
  set_table_name "people"
end
ARPerson1.establish_connection(conn)
ARPerson1.new # Have AR scan the table before the benchmark

ARPerson1.connection.execute("TRUNCATE TABLE people")

if ActiveRecord::VERSION::MAJOR == 3
  class ARPerson2 < ActiveRecord::Base
    set_table_name "people"
  end
  ARPerson2.establish_connection(conn.merge(:adapter => "mysql2"))
  ARPerson2.new # Have AR scan the table before the benchmark
end

require "sequel"

conn = {
  :socket => "/tmp/mysql.sock",
  :encoding => "utf8",
  :user => "root",
  :database => "people_test"
}

PEOPLE_DB1 = Sequel.mysql(conn)
PEOPLE_DB2 = Sequel.mysql2(conn)

class SPerson1 < Sequel::Model
  self.set_dataset PEOPLE_DB1[:people]
end
SPerson1.new

class SPerson2 < Sequel::Model
  self.set_dataset PEOPLE_DB2[:people]
end
SPerson2.new

require "rbench"

RBench.run(10_000) do
  column :times

  column :init, :title => ".new"
  column :insert
  column :select

  report "Hash" do
    init do
      Hash.new
    end
  end

  report "ActiveRecord #{ActiveRecord::VERSION::STRING} mysql" do
    init do
      ARPerson1.new
    end

    insert do
      ARPerson1.create!(:email => "foo#{Time.now.to_f}@email.test")
    end

    select do
      ARPerson1.limit(100).to_a
      #ARPerson1.where("created_at <= ?", Time.now).to_a
    end
  end

  ARPerson1.connection.execute("TRUNCATE TABLE people")

  if ActiveRecord::VERSION::MAJOR == 3
    report "ActiveRecord #{ActiveRecord::VERSION::STRING} mysql-2" do
      init do
        ARPerson2.new
      end

      insert do
        ARPerson2.create!(:email => "foo#{Time.now.to_f}@email.test")
      end

      select do
        ARPerson2.limit(100).to_a
        #ARPerson2.where("created_at <= ?", Time.now).to_a
      end
    end
  end

  ARPerson1.connection.execute("TRUNCATE TABLE people")

  report "Sequel mysql" do
    init do
      SPerson1.new
    end

    insert do
      SPerson1.create(:email => "foo#{Time.now.to_f}@email.test", :created_at => Time.now)
    end

    select do
      SPerson1.limit(100).all
      #SPerson1.filter("created_at <= ?", Time.now)
    end
  end

  ARPerson1.connection.execute("TRUNCATE TABLE people")

  report "Sequel mysql-2" do
    init do
      SPerson2.new
    end

    insert do
      SPerson2.create(:email => "foo#{Time.now.to_f}@email.test", :created_at => Time.now)
    end

    select do
      SPerson2.limit(100).all
      #SPerson2.filter("created_at <= ?", Time.now)
    end
  end

  ARPerson1.connection.execute("TRUNCATE TABLE people")

end

