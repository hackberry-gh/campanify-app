class Content::WidgetsController < Content::BaseController
  scopes 
  finder_method :find_by_id
    
  layout "embed"
end
