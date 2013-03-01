module Watchdog
  
  extend ActiveSupport::Concern

  autoload :ActivityListener, "watchdog/activity_listener"

  module ClassMethods

    def watchdog_listeners
      @watchdog_listeners ||= []
    end

    def watchdog_watchers
      @watchdog_watchers ||= []
    end

  	def method_added(method)
      self.watchdog_listeners.each do |dog|
        old_method = get_old_method_name(dog[:listener], dog[:method])
        if dog[:method] == method && !self.watchdog_watchers.include?(old_method)
      		release_listener(method, dog[:listener])
      	end
      end
  	end
    
    def watch(*args)
      args.each do |method|
        raise ArgumentError if method.nil?
        watch_with(method, ActivityListener)
      end
    end
    
    def watch_with(method, listener)
      if method_defined?(method)
        release_listener(method, listener)
      else
    	 self.watchdog_listeners << {method: method, listener: listener}
      end
    end

    def release_listener(method, listener)
    	old_method = get_old_method_name(listener, method)
      self.watchdog_watchers << old_method
      alias_method old_method, method
      define_method method do |*args|
        result = send old_method, *args
        listener.notify(self, method, result) if result
        result
      end
    end

    def get_old_method_name(listener, method)
      :"#{listener.to_s.parameterize.underscore}_#{method}"
    end 
    
  end

end
