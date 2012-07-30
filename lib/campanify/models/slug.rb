module Campanify
  module Models
    module Slug
      extend ActiveSupport::Concern
      included do
        before_save :set_slug
        cattr_accessor :slug_field
        validates_uniqueness_of :slug
      end
      module ClassMethods
        def slug(field_name)
          self.slug_field = field_name
        end
      end
      private
      def set_slug
        slug_builder = self[self.class.slug_field]        
        I18n.with_locale(I18n.default_locale) do
          self.slug = slug_builder.parameterize
        end
      end
    end
  end
end