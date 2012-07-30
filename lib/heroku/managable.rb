require 'heroku'

module Heroku
  module Managable
    extend ActiveSupport::Concern
    
    module ClassMethods
      def manage_with(slug)
        self.send :validates_presence_of, slug
        self.send :attr_accessible, :domains, :ps_web, :ps_worker
      end
    end

    def ps
      client.ps(slug)
    end

    def ps_web
      @ps_web ||= ps_count("web")
    end

    def ps_web=(count)
      @ps_web = ps_scale("web",count) unless new_record?
    end

    def ps_worker
      @ps_worker ||= ps_count("worker") 
    end

    def ps_worker=(count)
      @ps_worker ||= ps_scale("worker",count) if !new_record?
    end

    def domains
      @domains ||= client.list_domains(slug).map{|d| d[:domain]}
    end

    def domains=(added_domains)
      unless new_record?
        domains.each do |d|
          remove_domain(d) if !added_domains.include?(d)
        end
        added_domains.each do |d|
          add_domain(d) if !domains.include?(d) && !d.blank? && !d.empty? && !d.nil?
        end
        @domains = domains
      end
    end

    def add_domain(domain)
      client.add_domain(slug,domain) unless new_record?
    end

    def remove_domain(domain) 
      client.remove_domain(slug,domain) unless new_record?
    end

    def all_addons
      @all_addons ||= client.addons
    end
        
    def addons
      @addons ||= client.installed_addons(slug)
    end
    
    def addons=(added_addons)
      unless new_record?
        addons.each do |d|
          uninstall_addon(d) if !added_addons.include?(d)
        end
        added_addons.each do |d|
          install_addon(d) if !addons.include?(d) && !d.blank? && !d.empty? && !d.nil?
        end
        @addons = addons    
      end
    end

    def install_addon(addon, config={})
      client.install_addon(slug,addon) unless new_record?
    end

    def upgrade_addon(addon, config={}) 
      client.upgrade_addon(slug,addon) unless new_record?
    end
    
    def downgrade_addon(addon, config={}) 
      client.downgrade_addon(slug,addon) unless new_record?
    end
    
    def uninstall_addon(addon, config={}) 
      client.uninstall_addon(slug,addon) unless new_record?
    end
    
    def restart!
      (1..ps_web).each do |i|
        client.ps_restart(slug, :process => "web.#{i}")
      end
      (1..ps_worker).each do |i|
        client.ps_restart(slug, :process => "worker.#{i}")
      end      
    end

    def client
      @client ||= ::Heroku::Client.new(ENV['HEROKU_EMAIL'],ENV['HEROKU_API_KEY'])
    end

    private

    def ps_count(type)
      unless new_record?
        ps = client.ps(slug)
        ps = ps.keep_if{|p|p["process"].include?(type)}
        ps.size
      end
    end

    def ps_scale(type,qty)
      unless new_record?
        client.ps_scale(slug,{:type => type, :qty => qty})  
      end
    end
  end
end