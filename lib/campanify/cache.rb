# This class manages low level caching across application

module Campanify
  module Cache

    extend ActiveSupport::Concern

    # include Mongoid::Document
    # 
    # field :keys, type: Arra

    # returns cached value if available, writes new one if not
    def _cache(*keys, &block)
      key = _cache_key(keys)
      unless cached = Rails.cache.read( key )
        if block_given?
          cached = yield(block)
          Rails.cache.write(key, cached)
        end
      end
      cached
    end

    # returns cached value if available, 
    # writes new expirable by duration one if not
    def _smart_cache(expires_in, *keys, &block)
      key = _cache_key(keys)
      unless cached = Rails.cache.read( key )
        cached =  yield(block)          
        Rails.cache.write(key, cached, expires_in: expires_in)         
      end
      cached
    end

    # expires cache with given key args
    def _expire_cache(*keys)
      Rails.cache.delete( _cache_key(keys) )
    end

    # generates cache key with given args
    # best options are klass, method, id
    def _cache_key(*keys)
      # monkey patch to avoid SystemStackError: stack level too deep        
      if keys.to_s.include?("i18n_transliterate_rule")
        keys.to_s
      else
        keys.map(&:to_s).join(" ").parameterize.underscore          
      end  
    end

    ## Clears whole cache
    def _cache_clear
      Rails.cache.clear
    end


  end
end