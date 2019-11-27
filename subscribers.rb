# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "activesupport", require: false
  gem "dry-events"
  gem "wisper"

  gem "benchmark-ips"
end

require "dry/events/version"
require "active_support/notifications"
require "active_support/subscriber"
require "concurrent/utility/monotonic_time.rb"
require "active_support/version"

puts "ActiveSupport::Notifications %s" % ActiveSupport.version
puts "Dry::Events %s" % Dry::Events::VERSION
puts "Wisper %s" % Wisper::VERSION

PAYLOAD = { extra: :info }.freeze

AS_NOTIFICATIONS = lambda do |name|
  ActiveSupport::Notifications.instrument(name, PAYLOAD)
end

class DryPublisher
  include Dry::Events::Publisher[:my_publisher]

  register_event("test")
  register_event("test_block")
  register_event("test.subscriber")
end

@dry_app = DryPublisher.new
DRY_EVENTS = lambda do |name|
  @dry_app.publish(name, PAYLOAD)
end

class WisperPublisher
  include Wisper::Publisher

  def call(name)
    broadcast(name, PAYLOAD)
  end
end
@wisper = WisperPublisher.new
WISPER = lambda do |name|
  @wisper.call(name)
end

puts
puts "# ========="
puts "# Notifying (no subscribers)"
puts "# Tests general overhead of emitting events"
puts "# ========="
puts

Benchmark.ips do |x|
  x.report("AS::Notifications") do
    AS_NOTIFICATIONS.call("test")
  end

  x.report("Dry::Events") do
    DRY_EVENTS.call("test")
  end

  x.report("Wisper") do
    WISPER.call("test")
  end

  x.compare!
end

puts
puts "# ========="
puts "# Notifying (one subscriber)"
puts "# Tests overhead of calling defined subscribers"
puts "# ========="
puts

$msgs = {}

ActiveSupport::Notifications.subscribe("test_block") do |_name, _start, _finish, _id, _payload|
  $msgs["as-block"] = true
  true
end
class ASSubscriber < ActiveSupport::Subscriber
  attach_to :test

  def subscriber(_event)
    $msgs["as-sub"] = true
    true
  end
end

@dry_app.subscribe("test_block") do |_event|
  $msgs["dry-block"] = true
  true
end

class DrySubscriber
  def on_test_subscriber(_event)
    $msgs["dry-sub"] = true
    true
  end
end

@dry_app.subscribe(DrySubscriber.new)

@wisper.on("test_block") do |_payload|
  $msgs["wisper-block"] = true
  true
end

class WisperSubscriber
  def test_subscriber(_event)
    $msgs["wisper-sub"] = true
    true
  end
end
@wisper.subscribe(WisperSubscriber.new)

Benchmark.ips do |x|
  x.report("AS::N (block form)") do
    AS_NOTIFICATIONS.call("test_block")
  end

  x.report("AS::N (Subscriber)") do
    AS_NOTIFICATIONS.call("subscriber.test")
  end

  x.report("D::Events (block)") do
    DRY_EVENTS.call("test_block")
  end

  x.report("D::Events (Sub)") do
    DRY_EVENTS.call("test.subscriber")
  end

  x.report("Wisper (block)") do
    WISPER.call("test_block")
  end

  x.report("Wisper (Sub)") do
    WISPER.call(:test_subscriber)
  end

  x.compare!
end

fail "Not every subscriber was called!\n#{$msgs.keys.inspect}" unless $msgs.keys.size == 6

__END__
ActiveSupport::Notifications 6.0.1
Dry::Events 0.2.0
Wisper 2.0.1

# =========
# Notifying (no subscribers)
# Tests general overhead of emitting events
# =========

Warming up --------------------------------------
   AS::Notifications   200.994k i/100ms
         Dry::Events   195.141k i/100ms
              Wisper    37.135k i/100ms
Calculating -------------------------------------
   AS::Notifications      2.926M (±10.9%) i/s -     14.472M in   5.016570s
         Dry::Events      2.965M (± 5.0%) i/s -     14.831M in   5.016985s
              Wisper    370.067k (±20.1%) i/s -      1.782M in   5.098918s

Comparison:
         Dry::Events:  2964651.2 i/s
   AS::Notifications:  2926069.1 i/s - same-ish: difference falls within error
              Wisper:   370066.5 i/s - 8.01x  slower


# =========
# Notifying (one subscriber)
# Tests overhead of calling defined subscribers
# =========

Warming up --------------------------------------
  AS::N (block form)    35.116k i/100ms
  AS::N (Subscriber)    14.229k i/100ms
   D::Events (block)    68.656k i/100ms
     D::Events (Sub)    59.719k i/100ms
      Wisper (block)    14.473k i/100ms
        Wisper (Sub)    14.500k i/100ms
Calculating -------------------------------------
  AS::N (block form)    443.813k (± 8.7%) i/s -      2.212M in   5.034732s
  AS::N (Subscriber)    147.667k (± 5.7%) i/s -    739.908k in   5.027450s
   D::Events (block)    806.820k (± 8.9%) i/s -      4.051M in   5.066114s
     D::Events (Sub)    720.719k (±14.0%) i/s -      3.523M in   5.023177s
      Wisper (block)    154.804k (± 8.2%) i/s -    781.542k in   5.085598s
        Wisper (Sub)    147.813k (± 7.4%) i/s -    739.500k in   5.031281s

Comparison:
   D::Events (block):   806820.1 i/s
     D::Events (Sub):   720718.7 i/s - same-ish: difference falls within error
  AS::N (block form):   443813.2 i/s - 1.82x  slower
      Wisper (block):   154803.5 i/s - 5.21x  slower
        Wisper (Sub):   147812.8 i/s - 5.46x  slower
  AS::N (Subscriber):   147666.7 i/s - 5.46x  slower
