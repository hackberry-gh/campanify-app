namespace :load do
  
  COUNTRY_CODES = ['AR',
  'BE','BZ','DO',
  'EC','EG','SV','GQ','EE','ET','FK','FO','FJ','FI',
  'FR','FX','TF','GA','GM','GE','DE','GH','GI','GB',
  'GR','GL','GD','GP','GU','GT','GN','GW','GY','GF',
  'HT','HM','HN','HK','HU','IS','IN','ID','IR','IQ',
  'IE','IE','IL','IT','CI','JM','JP','JO','KZ','KE',
  'KG','KI','KP','KR','KW','LA','LV','LB','LS','LR',
  'LY','LI','PM','ST',
  'KN','VC','SD','SR','SJ','SZ','SE','CH','SY','TJ',
  'TC','TV','UG','UA','AE','GB','US','UY','UM','UZ',
  'ZW']

  def time_freeze period
    past = {hour:24, day:7, month:12}[period]
    from = Time.now - past.send(period)
    to = Time.now
    cdt = Time.at(from + rand * (to.to_f - from.to_f))
    Timecop.freeze(cdt)
  end
  def generate(k1,k2,period)
    period = period.to_sym
    puts "Generation started for #{k1} users with #{k2} visits data at #{Time.now}"
    lid = User.count> 0 ? User.order(:id).all.last.id : 0
    s1 = lid+1
    s2 = k1+s1
    (s1..s2).each do |i|
      
      time_freeze period
      
      u = User.create!(email: "email#{i}@email.com", first_name: "Test", last_name: "Test", country: COUNTRY_CODES.sample)
      
      Timecop.return
      
      (1..k2).each do |v|
        time_freeze period
        
        u.current_ip = v.to_s # rand(1234567890).to_s
        
        u.inc_visits
        
        Timecop.return        
      end
      
      puts u.id
    end
    puts "Generation finished for #{k1} users with #{k2} visits data at #{Time.now}"    
  end

  desc "loads 10 of users with max 5 visit data"
  task :nano => :environment do
    %w(hour day month).each_with_index do |p|
      generate(10,1 + Random.rand(4),p)
    end
  end
  
  desc "loads 100 of users with max 10 visit data"
  task :micro => :environment do
    %w(hour day month).each_with_index do |p|
      generate(100,1 + Random.rand(9),p)
    end
  end
    # 
    # desc "loads 1k of users with 100 visit data"
    # task :small, [:period] => :environment do |t, args|
    #   generate(1000,100,args[:period])
    # end
    # 
    # desc "loads 10k of users with 1k visit data"
    # task :medium, [:period] => :environment do |t, args|
    #   
    #   generate(10000,1000,args[:period])
    # end  
    # 
    # desc "loads 100k of users with 10k visit data"
    # task :large, [:period] => :environment do |t, args|
    #   
    #   generate(100000,10000,args[:period])
    # end  
    # 
    # desc "loads 1m of users with 250k visit data"
    # task :huge, [:period] => :environment do |t, args|
    #   
    #   generate(1000000,250000,args[:period])
    # end  
    # 
    # desc "loads 10m of users with 1m visit data"
    # task :giant, [:period] => :environment do |t, args|
    #   
    #   generate(10000000,1000000,args[:period])
    # end  
  
end