module Campanify
  module Controllers  
    module ActionCacheController
      extend ActiveSupport::Concern

      included do
        caches_action :index, 
                      layout: false, 
                      :cache_path => :index_cache_path.to_proc
        caches_action :show, 
                      layout: false, 
                      :cache_path => :show_cache_path.to_proc                
        cache_sweeper :content_sweeper

        helper_method :index_cache_path, :show_cache_path
      end

      def index_cache_path
        _cache_key(content_class_name, "index", params[:page] || 1, params[:sort] || "none", I18n.locale, current_branch || "none")
      end

      def show_cache_path
        _cache_key(content_class_name, "show", params[:id], I18n.locale, current_branch || "none")   
      end
    end
  end
end