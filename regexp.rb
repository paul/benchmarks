
require 'rubygems'
require 'rbench'

TIMES = 1_000

short =  lambda { |i| %r{^foo#{i}} }
medium = lambda { |i| %r{(foo|bar)#{i}} }
long =   lambda { |i| %r{(cpu,|load,shortterm$|memory,|disk,[^,]+,disk_time,),#{i}} }

HUNDRED_SHORT = (1..100).to_a.map(&short)
HUNDRED_MEDIUM = (1..100).to_a.map(&medium)
HUNDRED_LONG = (1..100).to_a.map(&long)

THOUSAND_SHORT = (1..1000).to_a.map(&short)
THOUSAND_MEDIUM = (1..1000).to_a.map(&short)
THOUSAND_LONG = (1..1000).to_a.map(&short)

RBench.run(TIMES) do

  column :times
  column :short,  :title => "^foo42"
  column :medium, :title => "(foo|bar)42"
  column :long,   :title => "(cpu,|load,shortterm$|memory,|disk,[^,]+,disk_time,)42"


  report "100 regexps" do
    short do 
      HUNDRED_SHORT.select { |re| "foo42" =~ re }
    end
    medium do
      HUNDRED_MEDIUM.select { |re| "asdfbar42" =~ re }
    end
    long do
      HUNDRED_LONG.select { |re| "apollo,memory,42" }
    end
  end

  report "1K regexps" do
    short do 
      THOUSAND_SHORT.select { |re| "foo42" =~ re }
    end
    medium do
      THOUSAND_MEDIUM.select { |re| "asdfbar42" =~ re }
    end
    long do
      THOUSAND_LONG.select { |re| "apollo,memory,42" }
    end
  end

end

