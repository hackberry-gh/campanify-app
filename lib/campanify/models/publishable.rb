module Campanify
  module Models
    module Publishable
      extend ActiveSupport::Concern
      included do
        before_save :set_publish_date
        scope :published, -> { where("published_at <= ?", DateTime.now) }
      end
      def published?
        published_at ? published_at < Time.now  : false
      end
      
      def unpublish!
        self.update_column(:published_at, nil)
      end
      
      def publish!
        self.update_column(:published_at, Time.now)        
      end
      
      private
      
      def set_publish_date
        self.published_at = DateTime.now unless self.published_at
      end
    end
  end
end