require 'date'
require 'time'
require 'benchmark'


def parse_by_split(str)
  day, time = str.split(':', 2)

  day, month, year = day.split('/')
  month = Date::ABBR_MONTHNAMES.index(month)

  hour, minute, second = time.split(':')
  second, offset = second.split(' ')

  Time.utc(year.to_i, month, day.to_i, hour.to_i, minute.to_i, second.to_f)
end

def parse_by_split_mktime(str)
  day, time = str.split(':', 2)

  day, month, year = day.split('/')
  month = Date::ABBR_MONTHNAMES.index(month)

  hour, minute, second = time.split(':')
  second, offset = second.split(' ')

  Time.mktime(second.to_f, minute.to_i, hour.to_i, day.to_i, month.to_i, year.to_i, nil, nil, nil, offset)
end

REGEX = /(\d+)\/(\w+)\/(\d+):(\d+):(\d+):(\d+) (-?\d+)/
def parse_by_regex(str)
  match = REGEX.match(str)
  month = Date::ABBR_MONTHNAMES.index(match[2])
  Time.utc(match[3].to_i, month, match[1].to_i, match[4].to_i, match[5].to_i, match[6].to_f)
end

def parse_by_regex_mktime(str)
  match = REGEX.match(str)
  month = Date::ABBR_MONTHNAMES.index(match[2])
  Time.mktime(match[6].to_i, match[5].to_i, match[4].to_i, match[1].to_i, month, match[3].to_i, nil, nil, nil, match[7])
end

STRING = "01/Aug/2011:13:26:51 -0700"

N = 10_000_000
Benchmark.bm(20) do |bm|
  bm.report("split - utc") do
    N.times { parse_by_split(STRING) }
  end

  bm.report("regex - utc") do
    N.times { parse_by_regex(STRING) }
  end

  bm.report("split - mktime") do
    N.times { parse_by_split_mktime(STRING) }
  end

  bm.report("regex - mktime") do
    N.times { parse_by_regex_mktime(STRING) }
  end
end


