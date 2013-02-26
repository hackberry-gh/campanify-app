class Content::PagesController < ::CampanifyController
  
  include Campanify::Controllers::ContentController
  include Campanify::Controllers::ActionCacheController
  scopes :published
  finder_method :find_by_slug
  
end
