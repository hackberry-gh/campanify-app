module Campanify
  module Controllers
    module TemplateController
      extend ActiveSupport::Concern
      included do
        prepend_view_path Appearance::Template::Resolver.instance
      end
    end
  end
end