
require "benchmark/ips"

require "active_support/callbacks"

class NormalMethod

  def simple(req, opts)
    callback(req, opts) do
      perform(req, opts)
    end
  end

  def deep(req, opts)
    callback(req, opts) do
      callback(req, opts) do
        callback(req, opts) do
          callback(req, opts) do
            callback(req, opts) do
              callback(req, opts) do
                callback(req, opts) do
                  callback(req, opts) do
                    callback(req, opts) do
                      callback(req, opts) do
                        perform(req, opts)
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def perform(req, opts)
    :result
  end

  def callback(req, opts)
    :before
    r = yield req, opts
    :after
    r
  end
end

class NaiveMethod
  def simple(req, opts)
    initial = method(:perform)
    [method(:callback)].reverse.inject(initial) do |result, hook|
      lambda { |req, opts| hook.call req, opts, &result }
    end.call(req, opts)
  end

  def deep(req, opts)
    initial = method(:perform)

    ([method(:callback)] * 10).inject(initial) do |result, hook|
      lambda { |req, opts| hook.call req, opts, &result }
    end.call(req, opts)
  end

  def perform(req, opts)
    :result
  end

  def callback(req, opts)
    :before
    r = yield req, opts
    :after
    r
  end
end

class SimpleASCallback
  include ActiveSupport::Callbacks

  define_callbacks :perform

  set_callback :perform, :around, :callback

  def perform(req, opts)
    run_callbacks :perform do
      :perform
    end
  end

  # AS Callbacks don't support args
  def callback
    :before
    r = yield
    :after
    r
  end
end

class DeepASCallback
  include ActiveSupport::Callbacks

  define_callbacks :perform

  10.times do
    set_callback :perform, :around, :callback
  end

  def perform(req, opts)
    run_callbacks :perform do
      :perform
    end
  end

  # AS Callbacks don't support args
  def callback
    :before
    r = yield
    :after
    r
  end
end

NORMAL = NormalMethod.new
NAIEVE = NaiveMethod.new
AS_CALLBACK_SIMPLE = SimpleASCallback.new
AS_CALLBACK_DEEP = DeepASCallback.new

Benchmark.ips do |x|
  x.report("normal methods") { NORMAL.simple(:req, {}) }
  x.report("naive w/ init")  { NAIEVE.simple(:req, {}) }
  x.report("as::cb w/ init") { AS_CALLBACK_SIMPLE.perform(:req, {}) }

  x.report("deeply nested normal") { NORMAL.deep(:req, {}) }
  x.report("deeply nested naieve") { NAIEVE.deep(:req, {}) }
  x.report("deeply nested as::cb") { AS_CALLBACK_DEEP.perform(:req, {}) }
end

__END__


Warming up --------------------------------------
      normal methods   144.326k i/100ms
       naive w/ init    14.347k i/100ms
      as::cb w/ init     9.935k i/100ms
deeply nested normal    53.992k i/100ms
deeply nested naieve     7.035k i/100ms
deeply nested as::cb    10.719k i/100ms
Calculating -------------------------------------
      normal methods      3.741M (±10.4%) i/s -     18.329M in   5.005264s
       naive w/ init    264.077k (±25.9%) i/s -      1.234M in   5.052112s
      as::cb w/ init    144.795k (±15.9%) i/s -    705.385k in   5.029092s
deeply nested normal    970.831k (± 4.8%) i/s -      4.859M in   5.017069s
deeply nested naieve     86.007k (±27.2%) i/s -    400.995k in   5.115914s
deeply nested as::cb    147.859k (±15.7%) i/s -    728.892k in   5.076820s

