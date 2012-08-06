namespace :load do
  
  COUNTRY_CODES = ['AF','AL','DZ','AS','AD','AO','AI','AQ','AG','AR',
  'AM','AW','AU','AT','AZ','BS','BH','BD','BB','BY',
  'BE','BZ','BJ','BM','BO','BA','BW','BV','BR','IO',
  'BN','BG','BF','BI','BT','KH','CM','CA','CV','KY',
  'CF','TD','CL','CN','CX','CC','CO','KM','CG','CK',
  'CR','HR','CU','CY','CZ','DK','DJ','DM','DO',
  'EC','EG','SV','GQ','EE','ET','FK','FO','FJ','FI',
  'FR','FX','TF','GA','GM','GE','DE','GH','GI','GB',
  'GR','GL','GD','GP','GU','GT','GN','GW','GY','GF',
  'HT','HM','HN','HK','HU','IS','IN','ID','IR','IQ',
  'IE','IE','IL','IT','CI','JM','JP','JO','KZ','KE',
  'KG','KI','KP','KR','KW','LA','LV','LB','LS','LR',
  'LY','LI','LT','LU','LB','LS','LR','LY','LI','LT',
  'LU','ME','MO','MG','MW','MY','MV','ML','MT','MH','MQ',
  'MR','MU','MX','FM','MD','MC','MN','MS','MA','MZ',
  'MM','MK','NA','NR','NP','NO','AN','NL','NC','NZ','NI','NE',
  'NG','NU','NF','MP','OM','PK','PW','PA','PG','PY',
  'PE','PH','PN','PL','PF','PT','PR','PS','QA','RE','RO','RS',
  'RU','RW','LC','WS','SM','SA','SN','SC','SL','SG',
  'SK','SI','SB','SO','ZA','ES','LK','SH','PM','ST',
  'KN','VC','SD','SR','SJ','SZ','SE','CH','SY','TJ',
  'TW','TZ','TH','TG','TK','TO','TT','TN','TR','TM',
  'TC','TV','UG','UA','AE','GB','US','UY','UM','UZ',
  'VU','VA','VE','VN','VG','VI','WF','EH','YE','ZM',
  'ZW']
  
  class Time
    def self.random(years_back=5)
      year = Time.now.year - rand(years_back) - 1
      month = rand(12) + 1
      day = rand(31) + 1
      Time.local(year, month, day)
    end
  end
  
  def generate(k1,k2)
      
    Campanify::Models::History.class_eval do
      private
      def time_stamp
        t = Time.random
        "#{t.year}.#{t.month}.#{t.day}.#{t.hour}"
      end
    end
    
    puts "Generation started for #{k1} users with #{k2} visits data at #{Time.now}"
    User.delete_all
    (1..k1).each do |i|
      u = User.create!(email: "email#{i}@email.com", first_name: "Test", last_name: "Test", country: COUNTRY_CODES.sample)
      (1..k2).each do |v|
        u.current_ip = v.to_s # rand(1234567890).to_s
        u.inc_visits
      end
      puts u.id
    end
    puts "Generation finished for #{k1} users with #{k2} visits data at #{Time.now}"    
  end

  desc "loads 1k of users with 1k visit data"
  task :small => :environment do
    generate(1000,1000)
  end
  
  desc "loads 10k of users with 10k visit data"
  task :medium => :environment do
    generate(10000,1000)
  end  
  
  desc "loads 100k of users with 100k visit data"
  task :large => :environment do
    generate(100000,100000)
  end  
  
  desc "loads 1m of users with 250k visit data"
  task :huge => :environment do
    generate(1000000,250000)
  end  
  
  desc "loads 10m of users with 1m visit data"
  task :giant => :environment do
    generate(10000000,1000000)
  end  
  
end