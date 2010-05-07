

require 'rubygems'
require 'rbench'

TIMES = 100_000


SHORT =  "^foo"
MEDIUM = "(foo|bar)"
LONG =   "(cpu,|load,shortterm$|memory,|disk,[^,]+,disk_time,)"

SHORT_M =  Marshal.dump(/#{SHORT}/)
MEDIUM_M = Marshal.dump(/#{MEDIUM}/)
LONG_M =   Marshal.dump(/#{LONG}/)

RBench.run(TIMES) do

  column :times
  column :init, :title => "Regexp.new"
  column :marshall, :title => "Marshall.load"

  report "short regexp" do
    init do
      Regexp.new(SHORT)
    end
    marshall do
      Marshal.load(SHORT_M)
    end
  end

  report "medium regexp" do
    init do
      Regexp.new(MEDIUM)
    end
    marshall do
      Marshal.load(MEDIUM_M)
    end
  end
  report "long regexp" do
    init do
      Regexp.new(LONG)
    end
    marshall do
      Marshal.load(LONG_M)
    end
  end

end
