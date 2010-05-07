require 'rubygems'
require 'rbench'
require 'time'

TIMES = 100_000

TIME = Time.now.utc
TIME_STR = TIME.httpdate

RBench.run(TIMES) do

  column :string, :title => "str == max.httpdate"
  column :at, :title => "Time.rfc2822(str) >= Time.at(max.to_i)"
  column :rfc, :title => "Time.rfc2822(str) >= Time.rfc2822(max.rfc2822)"

  report("time") do
    string { TIME_STR == TIME.httpdate }
    at     { Time.rfc2822(TIME_STR) >= Time.at(TIME.to_i) }
    rfc    { Time.rfc2822(TIME_STR) >= Time.rfc2822(TIME.rfc2822) }
  end

end
