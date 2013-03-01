module Campanify
  module Models
    module Popularity

      extend ActiveSupport::Concern
      
      included do
        raise ArgumentError, "Popularity module needs History Module included" unless self.included_modules.include?(Campanify::Models::History)
        
        attr_accessor :dirty_tracks
        attr_accessible :popularity, :dirty_tracks        
      end
      
      private
      
      def update_historical_field(field_name, action, value, owner)
        if current_ip && owner
          self.dirty_tracks = {}
          self.class.tracking_fields.each do |tf|
            self.dirty_tracks[tf] = self.send("total_#{tf}".to_sym)
          end
          result = super(field_name, action, value, owner)     
          update_popularity   
          result
        end
      end
      
      def update_popularity
        current_popularity = self.popularity || 0
        self.class.tracking_fields.each do |tf|
          diff = self.send("total_#{tf}".to_sym) - self.dirty_tracks[tf]
          current_popularity = apply_diff(current_popularity, diff)
          
          if self.respond_to?(:user) && self.user.respond_to?(:popularity)
            self.user.update_column(:popularity, apply_diff(self.user.popularity || 0, diff))
          end
        end  
        self.dirty_tracks = {}      
        update_column(:popularity, current_popularity)
      end
      
      def apply_diff(current_popularity, diff)
        if diff > 0
          current_popularity = current_popularity + 1
        elsif diff < 0
          current_popularity = current_popularity - 1
        end
        current_popularity
      end
      
    end
  end
end