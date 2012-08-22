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
      # require 'rake'
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
      
      # wait until sendgrid setup done
      until client.get_config_vars(slug).body["SENDGRID_USERNAME"].present? &&
            client.get_config_vars(slug).body["SENDGRID_PASSWORD"].present?
        sleep(1)
      end
      
      puts "CONFIG"
      puts client.get_config_vars(slug).body
      
      # migrate db if PLAN is not town
      if ENV['PLAN'] != 'town'
        migrate_db(Campanify::Plans.configuration(:town),config)  
      end
    end
    
    private

    def change_plan(target_plan)
      if target_plan != self.plan
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
      
        migrate_db(current_config,config)

        # change plan environment var
        client.put_config_vars(slug, 'PLAN' => plan)     
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
    
    def migrate_db(current_config,config)
      # put app on maintenance mode
      client.post_app_maintenance(slug, 1)
      
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
      
      # remove app from maintenance mode
      client.post_app_maintenance(slug, 0)
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