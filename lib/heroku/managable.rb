require 'heroku-api'

module Heroku
  module Managable
    extend ActiveSupport::Concern
    
    module ClassMethods
      def manage_with(slug)
        # validates_presence_of slug    
        attr_accessible :plan, :price, :domains, :ps_web, :ps_worker
      end
    end

    def domains
      client.get_domains(slug).body.map{|domain| domain["domain"]}
    end
    
    def domains=(new_domains)
      currents = domains.dup
      new_domains.each{|e| currents.include?(e) ? currents.delete(e) : currents.push(e) }
      currents.each{|domain| client.post_domain(slug,domain.strip)}
    end
    
    def plan
      ENV['PLAN']
    end
    
    def plan=(plan)
      change_plan(plan)
    end
    
    def price
      addon_price = client.get_addons(slug).body.sum{|addon| addon["price"]["cents"]}
      ps_price = (client.get_ps(Campaign.first.slug).body.count - 1) * 3500
      campanify_price = Campanify::Plans.configuration(plan.to_sym)[:price]
      addon_price + ps_price + campanify_price
    end
    
    def restart!
      client.post_ps_restart(slug)
    end
    
    def setup
      require 'rake'
      config = Campanify::Plans.configuration(ENV['PLAN'].to_sym)          
      # scale
      puts "SCALING"
      config[:ps].each do |type, quantity|
        ps_scale(type, quantity)
      end
      # updgrade/downgrade addons
      puts "INSTALLING ADDONS"            
      config[:addons].each do |addon, plan|
        post_addon("#{addon}:#{plan}")
      end
      # add db
      # puts "CREATING DB"      
      # client.post_addon(slug, config[:db])      
    end
    
    private

    def change_plan(target_plan)
      if target_plan != self.plan
        # put app on maintenance mode
        client.post_app_maintenance(slug, 1)
      
        # get config of plan
        current_config = Campanify::Plans.configuration(ENV['PLAN'].to_sym)
        config = Campanify::Plans.configuration(target_plan.to_sym)
      
        # scale
        config[:ps].each do |type, quantity|
          ps_scale(type, quantity)
        end
      
        # updgrade/downgrade addons
        config[:addons].each do |addon, plan|
          put_addon("#{addon}:#{plan}")
        end
      
        # db migration
        # ============

        # add new db addon
        client.post_addon(slug, config[:db])
    
        # capture backup of current db
        system('heroku pgbackups:capture --expire')
    
        # get new db url
        config_vars = client.get_config_vars(slug)
        target_db = config_vars.
                    delete_if{|key,value| !key.include?('POSTGRESQL')}.
                    delete_if{|key,value| value == config_vars['DATABASE_URL']}.
                    keys.first
    
        # restore new db from backup
        system("heroku pgbackups:restore #{target_db}")
    
        # promote new db
        system("heroku pg:promote #{target_db}")
    
        # remove old db addon
        client.delete_addon(slug, current_config[:db])

        # change plan environment var
        client.put_config_vars(slug, 'PLAN' => plan)
      
        # remove app from maintenance mode
        client.post_app_maintenance(slug, 0)      
      end
    end
    
    def ps_scale(type, quantity)
      client.post_ps_scale(slug, type, quantity)
    end
    
    def put_addon(addon)
      client.put_addon(slug, addon)
    end
    
    def post_addon(addon)
      client.post_addon(slug, addon)
    end

    def client
      @client ||= ::Heroku::API.new
    end
    
    if ENV['PLAN'] != "town"
      handle_asynchronously :restart!
      handle_asynchronously :change_plan
    end
    
  end
end