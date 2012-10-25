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

__END__

» ruby --version
ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-darwin11.4.1]

Time.new(...) | Time.at(int) | Time.parse(iso8601) | Time.parse(http) | Time.iso8601(iso8601) | Time.httpdate(http) |
---------------------------------------------------------------------------------------------------------------------
        2.666 |        0.028 |               3.933 |            4.218 |                 1.237 |               1.898 |
