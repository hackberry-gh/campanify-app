desc "benchmarking"
task :benchmark => :environment do
  require 'benchmark'
  User.delete_all
  user = User.create!(email: "test@test.com", first_name: "test", last_name: "test")
  n = 1
  Benchmark.bmbm(8) do |x|
    # x.report { for i in 1..n; user.inc_visits; end }
    x.report(:hourly) { for i in 1..n; user.current_ip = i.to_s; user.inc_visits; user.hourly_visits(false); end }    
    x.report(:daily) { for i in 1..n; user.current_ip = i.to_s; user.inc_visits; user.daily_visits(false); end }
    x.report(:monthly) { for i in 1..n; user.current_ip = i.to_s; user.inc_visits; user.monthly_visits(false); end }    
    x.report(:yearly) { for i in 1..n; user.current_ip = i.to_s; user.inc_visits; user.yearly_visits(false); end }        
    x.report(:total) { for i in 1..n; user.current_ip = i.to_s; user.inc_visits; user.total_visits(false); end }
  end
  user.destroy
end