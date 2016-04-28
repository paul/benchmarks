
require 'benchmark/ips'
require 'em-synchrony'
require 'em-synchrony/em-http'

EventMachine.synchrony do

  GOOGLE = "http://google.com/"

  multi = EventMachine::Synchrony::Multi.new
  start = Time.now
  10_000.times do |i|
    multi.add i.to_s.intern, EventMachine::HttpRequest.new(GOOGLE).aget
  end
  added_done = Time.now
  res = multi.perform
  finish = Time.now

  File.write("out.txt", res.responses)



  added = added_done - start
  puts "Adding %0.4f (%0.4f req/s)" % [added, added / 10_000]

  performed = finish - start
  puts "Performed %0.4f (%0.4f req/s)" % [performed, performed / 10_000]

  EventMachine.stop
end
