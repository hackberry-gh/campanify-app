class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include Campanify::Controllers::TemplateController  
  include Campanify::Controllers::ReferralsController 
  include Campanify::Controllers::IpCountryBranchController     
  include Campanify::Cache  
end
