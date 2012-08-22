class Content::PagesController < ::CampanifyController
  include Campanify::Controllers::ContentController
  scopes :published
  finder_method :find_by_slug
end
