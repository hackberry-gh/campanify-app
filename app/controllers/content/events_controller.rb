class Content::EventsController < ::CampanifyController
  include Campanify::Controllers::ContentController
  scopes :public
  finder_method :find_by_slug
end
