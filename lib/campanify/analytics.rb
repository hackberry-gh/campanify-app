module Analytics
  include Campanify::Cache
  
  EXPIRES_IN = 1.hour
      
  module Users
      
    def most_populars(page = 1, per = 10)
      _smart_cache EXPIRES_IN, "analytics_users_most_populars" do
        User.populars.page(page).per(per)
      end
    end
    
    def most_populars_by_country(country)
      _smart_cache EXPIRES_IN, "analytics_users_most_populars_by_country_#{country}" do
        User.populars.where(:country => country).page(page).per(per)
      end      
    end
    
    module Trending

      # def distrubution_on_countries
      #   _smart_cache EXPIRES_IN, "analytics_users_trending_distrubution_on_countries" do
      # 
      #   end
      # end
      def by_country(country)
        _smart_cache EXPIRES_IN, "analytics_users_trending_by_country_#{country}" do
          User.where(:country => country).count
        end
      end
      def last_12_months
        counts_on_range_by_period( (0..11), :months)
      end    
      def last_4_weeks
        counts_on_range_by_period( (0..3), :weeks)
      end    
      def last_7_days
        counts_on_range_by_period( (0..6), :days)
      end    
      def last_24_hours
        counts_on_range_by_period( (0..23), :hours)
      end
      def counts_on_range_by_period(range, period)
        counts = []
        range.each do |unit|
          counts << count_by_time_span(DateTime.now - (unit+1).send(period), DateTime.now - unit.send(period))
        end
        counts
      end
      def count_by_time_span(start_time, end_time)
        _smart_cache EXPIRES_IN, "analytics_users_trending_count_by_time_span_#{start_time.to_s.parameterize}_#{end_time.to_s.parameterize}" do 
          User.where(["created_at >= ? AND created_at <= ?", start_date, end_date]).count
        end
      end
      
    end
    
  end
  
end