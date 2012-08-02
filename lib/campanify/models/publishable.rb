module Campanify
  module Models
    module Publishable
      extend ActiveSupport::Concern
      included do
        before_create :set_publish_date
        scope :published, -> { where("published_at <= ?", DateTime.now) }
        scope :unpublished, -> { where("published_at >= ? OR published_at IS NULL", DateTime.now) }        
      end
      def published?
        published_at ? published_at < DateTime.now  : false
      end
      
      def unpublish!
        self.update_column(:published_at, nil)        
      end
      
      def publish!
        self.update_column(:published_at, DateTime.now)        
      end
      
      private
      
      def set_publish_date
        self.published_at ||= DateTime.now
      end
    end
  end
end