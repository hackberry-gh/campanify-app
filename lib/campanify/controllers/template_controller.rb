module Campanify
  module Controllers
    module TemplateController
      extend ActiveSupport::Concern
      included do
        prepend_view_path Appearance::Template::Resolver.instance unless Rails.env.development?
      end
    end
  end
end