class AnalyticsController < CampanifyController
  
  def index
  end
  
  def map
    @data = _smart_cache 1.day, "analytics_map" do 
      { :user_counts_by_country => User.find_by_sql("SELECT count(country) as user_count, country, meta FROM users WHERE country IS NOT NULL GROUP BY country,meta ORDER BY user_count DESC").map{|u| u.country = I18n.t(u.country, scope: :countries); u} }
    end  
    render :json => @data
  end
  
  def ranking
    @data = _smart_cache 10.minutes, "analytics_ranking", params[:page], params[:per] do 
      {
        :popular_users => User.popularity.
                          page(params[:page]).
                          per(params[:per] || Settings.pagination["per"]).to_a,
        :popular_posts => Content::Post.popularity.
                          page(params[:page]).
                          per(params[:per] || Settings.pagination["per"]).to_a
      }
    end
    render :layout => false
  end
  
  def graphs
    @data = _smart_cache 1.hour, "analytics_graphs" do 
      {
        :users => {
          :hourly => counts_by_period(User,'hour'),
          :daily => counts_by_period(User,'day'),
          :weekly => counts_by_period(User,'week'),        
          :monthly => counts_by_period(User,'month'),
          :total => User.count(:id)
        },
        :content_posts => {
          :hourly => counts_by_period(Content::Post,'hour'),
          :daily => counts_by_period(Content::Post,'day'),
          :weekly => counts_by_period(Content::Post,'week'),        
          :monthly => counts_by_period(Content::Post,'month'),
          :total => Content::Post.count(:id)
        }
      }
    end  
    render :json => @data    
  end    
  
  private 
  
  def counts_by_period(model, period)
    model.find_by_sql("SELECT extract('#{period}' from created_at) as #{period}, count(created_at) as #{model.to_s.parameterize.underscore.pluralize} FROM #{model.table_name} WHERE date_trunc('#{period}', created_at) = '#{Time.now.utc.send("beginning_of_#{period}").to_s(:db)}' GROUP BY #{period} ORDER BY #{period} DESC")
  end
  
end
