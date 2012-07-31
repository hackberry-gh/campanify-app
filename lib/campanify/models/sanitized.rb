module Campanify
  module Models
    module Sanitized
      extend ActiveSupport::Concern
      include ActionView::Helpers::SanitizeHelper
      included do
        before_save :sanitize_inputs
      end
      private
      def sanitize_inputs 
        self.attributes.each do |k,v|
          self[k] = strip_tags(sanitize(v)) if v.is_a?(String)
        end
      end
    end
  end
end