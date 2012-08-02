module Campanify
  module Models
    module Popularity

      extend ActiveSupport::Concern
      
      included do
        if self.included_modules.include?(Campanify::Models::History)
          # alias_method :update_historical_field_without_popularity, :update_historical_field
          after_update :calculate
          attr_accessor :dirty_tracks
          attr_accessible :popularity, :dirty_tracks        
        end
      end
      
      def update_historical_field(field_name, action, value, owner)
        self.dirty_tracks = {}
        self.class.tracking_fields.each do |tf|
          self.dirty_tracks[tf] = self.send("total_#{tf}".to_sym)
          puts "DIRTY #{tf} #{self.dirty_tracks[tf]}"
        end
        super(field_name, action, value, owner)        
      end
      
      def calculate
        current_popularity = self.popularity || 0
        self.class.tracking_fields.each do |tf|
          diff = self.send("total_#{tf}".to_sym) - self.dirty_tracks[tf]
          puts "DIFF #{diff} #{self.dirty_tracks[tf]} #{self.send("total_#{tf}".to_sym)}"
          if diff > 0
            current_popularity = current_popularity + 1
          elsif diff < 0
            current_popularity = current_popularity - 1
          end
        end  
        self.dirty_tracks = {}      
        update_column(:popularity, current_popularity)
      end
      
    end
  end
end