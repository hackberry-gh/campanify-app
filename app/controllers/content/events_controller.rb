class Content::EventsController < ::CampanifyController
  include Campanify::Controllers::ContentController
  include Campanify::Controllers::ActionCacheController
  scopes :public
  finder_method :find_by_slug
end
