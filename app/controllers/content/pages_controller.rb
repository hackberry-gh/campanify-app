class Content::PagesController < Content::BaseController
  scopes :published
  finder_method :find_by_slug
end
