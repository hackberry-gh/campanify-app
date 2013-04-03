module Campanify
  module Controllers
    module TemplateController
      extend ActiveSupport::Concern
      included do
        prepend_view_path Appearance::Template::Resolver.instance if Rails.env.production?
      end
    end
  end
end