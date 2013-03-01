class AnalyticsController < CampanifyController
  
  def index
  end
  
  def map
    @data = _smart_cache 10.minutes, "analytics_map" do 
      { :user_counts_by_country => User.find_by_sql("SELECT count(country) as user_count, country FROM users WHERE country IS NOT NULL GROUP BY country ORDER BY user_count DESC").map{|u| u.country = I18n.t(u.country, scope: :countries); u} }
    end  
    puts @data
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
    @data = _smart_cache 10.minutes, "analytics_graphs" do 
      {
        :users => {
          :daily => counts_by_period(User,'hour', 'day').map{|u| [u.time,u.counts]},
          :weekly => counts_by_period(User,'dow', 'week').map{|u| [u.time,u.counts]},
          :monthly => counts_by_period(User,'day', 'month').map{|u| [u.time,u.counts]},
          :yearly => counts_by_period(User,'month', 'year').map{|u| [u.time,u.counts]},          
          :total => User.count(:id)
        },
        :content_posts => {
          :daily => counts_by_period(Content::Post,'hour', 'day').map{|u| [u.time,u.counts]} ,
          :weekly => counts_by_period(Content::Post,'dow', 'week').map{|u| [u.time,u.counts]},
          :monthly => counts_by_period(Content::Post,'day', 'month').map{|u| [u.time,u.counts]},
          :yearly => counts_by_period(Content::Post,'month', 'year').map{|u| [u.time,u.counts]},          
          :total => Content::Post.count(:id)
        }
      }
    end  
    render :json => @data    
  end    
  
  private 
  
  def counts_by_period(model, period, parent)
    # model.find_by_sql("SELECT extract('#{period}' from created_at) as #{period}, count(created_at) as #{model.to_s.parameterize.underscore.pluralize} FROM #{model.table_name} WHERE date_trunc('#{period}', created_at) = '#{Time.now.utc.send("beginning_of_#{period}").to_s(:db)}' GROUP BY #{period} ORDER BY #{period} DESC")
    
    scope = model.select("extract('#{period}' from created_at) as time, count(created_at) as counts").
    where("date_trunc('#{parent}', created_at) = '#{Time.now.utc.send("beginning_of_#{parent}").to_s(:db)}'").
    group("time").order("time ASC")
  end
  
end
