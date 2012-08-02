class Content::EventsController < Content::BaseController
  scopes :public
  finder_method :find_by_slug
end
