module Campanify
  module ThreadedAttributes
    
    extend ActiveSupport::Concern
    
    module ClassMethods
      def threaded(attribute)
        attribute = attribute.to_s
        self.class_eval <<-CODE
        def current_#{attribute}=(#{attribute})
          Thread.current[:#{attribute}] = #{attribute}
        end

        def current_#{attribute}
          Thread.current[:#{attribute}]
        end
      
        def self.current_#{attribute}=(#{attribute})
          Thread.current[:#{attribute}] = #{attribute}
        end

        def self.current_#{attribute}
          Thread.current[:#{attribute}]
        end
        CODE
      end
    end
    
  end
end