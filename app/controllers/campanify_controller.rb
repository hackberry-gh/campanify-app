class CampanifyController < ApplicationController
  include Campanify::Controllers::TemplateController  
  include Campanify::Controllers::ReferralsController 
  include Campanify::Controllers::IpCountryBranchController     
  include Campanify::Cache
  
  helper_method :timezone
  
  def timezone
    begin
      Settings.branches[current_branch]['timezone']
    rescue
      Settings.timezone
    end
  end


end