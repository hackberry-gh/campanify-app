class Content::WidgetsController < ::CampanifyController
  
  include Campanify::Controllers::ContentController
  
  scopes 
  finder_method :find_by_id
    
  layout "embed"
end
