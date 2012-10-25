require 'rubygems'
require 'rbench'
require 'time'

TIMES = 100_000

TIME = Time.now.utc
TIME_ISO = TIME.iso8601
TIME_INT = TIME.to_i
TIME_HTTP = TIME.httpdate

RBench.run(TIMES) do

  column :new,        :title => "Time.new(...)"
  column :at,         :title => "Time.at(int)"
  column :parse_iso,  :title => "Time.parse(iso8601)"
  column :parse_http, :title => "Time.parse(http)"
  column :iso8601,    :title => "Time.iso8601(iso8601)"
  column :httpdate,   :title => "Time.httpdate(http)"

  report("time") do
    new        { Time.new(1,1,1,1,1,1)    }
    at         { Time.at(TIME_INT)        }
    parse_iso  { Time.parse(TIME_ISO)     }
    parse_http { Time.parse(TIME_HTTP)    }
    iso8601    { Time.iso8601(TIME_ISO)   }
    httpdate   { Time.httpdate(TIME_HTTP) }
  end

end
