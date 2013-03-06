module Campanify
	module CounterCacher
		extend ActiveSupport::Concern

		included do
			before_destroy :decrement_counter
			after_create :increment_counter
		end

		def increment_counter
			counter = CounterCache.find_or_create_by_model(self.class.to_s)
			counter.increment!(:count)
		end

		def decrement_counter
			if counter = CounterCache.find_by_model(self.class.to_s)
				counter.decrement!(:count)
			end
		end

		module ClassMethods

			def cached_count
				if counter = CounterCache.find_by_model(self.to_s)
					counter.count
				else
					0	
				end
			end

		end

	end
end