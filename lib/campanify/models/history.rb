module Campanify
  module Models
    module History

      class Track < ActiveRecord::Base
        self.table_name = "history_tracks"
        attr_accessible :value, :tracker, :ip, :owner_id, :target_id, :target_type
        
        scope :by_period, lambda{ |period| where("date_trunc('#{period}', created_at) = ?", Time.now.utc.send("beginning_of_#{period}").to_s(:db))}
        scope :by_tracker, lambda{ |tracker| where(tracker: tracker) }
        
        def self.periodic_rows_sum(parent, child, tracker, uniq = false)
          scope = select("extract('#{child}' from created_at) as time, sum(value)").
          where("tracker = '#{tracker}' AND date_trunc('#{parent}', created_at) = '#{Time.now.utc.send("beginning_of_#{parent}").to_s(:db)}'").
          group("time").order("time ASC")
          scope = scope.group(:ip) if uniq
          scope          
        end 
        
        def self.periodic_rows_avarage(parent, child, tracker, uniq = false)
          scope = select("extract('#{child}' from created_at) as time, avg(value)").
          where("tracker = '#{tracker}' AND date_trunc('#{parent}', created_at) = '#{Time.now.utc.send("beginning_of_#{parent}").to_s(:db)}'").
          group("time").order("time ASC")
          scope = scope.group(:ip) if uniq          
          scope
        end
      end

      extend ActiveSupport::Concern

      module ClassMethods
        
        def track(*args)
          args.each do |field_name|
            tracking_fields << field_name unless tracking_fields.include?(field_name)
            class_eval <<-CODE

            def inc_#{field_name}(owner = self)
              update_historical_field("#{field_name}", "inc", 1, owner)
            end
            def dec_#{field_name}(owner = self)
              update_historical_field("#{field_name}", "dec", 1, owner)
            end     
            def set_#{field_name}(value, owner = self)
              update_historical_field("#{field_name}", "set", value, owner)
            end

            def total_#{field_name}(uniq = true, owner = :all, target = self)
              count("#{field_name}", uniq, owner, target)
            end
            def yearly_#{field_name}(uniq = true, owner = :all, target = self)
              count("#{field_name}", uniq, owner, target, 'year')
            end
            def monthly_#{field_name}(uniq = true, owner = :all, target = self)
              count("#{field_name}", uniq, owner, target, 'month')
            end
            def daily_#{field_name}(uniq = true, owner = :all, target = self)
              count("#{field_name}", uniq, owner, target, 'day')
            end
            def weekly_#{field_name}(uniq = true, owner = :all, target = self)
              count("#{field_name}", uniq, owner, target, 'week')
            end            
            def hourly_#{field_name}(uniq = true, owner = :all, target = self)
              count("#{field_name}", uniq, owner, target, 'hour')
            end 

            def #{field_name}
              cache_getter = :"cached_uniq_#{field_name}"
              (self.respond_to?(cache_getter) ? self.send(cache_getter) : total_#{field_name}) || 0
            end               

            CODE
          end
        end
      end
      
      included do
        class_variable_set :@@tracking_fields, []
        cattr_accessor :tracking_fields
        include Campanify::ThreadedAttributes
        threaded :ip
      end

      private

      def update_historical_field(field_name, action, value, owner)
        
        if current_ip && owner
          uniq = false
          start_time = Time.now.utc.beginning_of_hour
          end_time = Time.now.utc.end_of_hour
          if current = Track.where('tracker = ? AND ip = ? AND owner_id = ? AND target_id = ? AND target_type = ? AND created_at >= ? AND created_at <= ?', 
            field_name, current_ip, owner.id, self.id, self.class.name, start_time, end_time).first
            current.update_column(:value, calculate(current.value, action, value))            
          else
            uniq = true
            current = Track.create!(:value => calculate(0, action, value), :tracker => field_name, :ip => current_ip, :owner_id => owner.id, 
            :target_id => self.id, :target_type => self.class.name)
          end

          # populate cache columns if available
          cache_setter = :"cached_uniq_#{field_name}="
          # update cache on uniq or decremental updates
          # because set and inc doesn't affect uniq counts if they are redundant
          if (uniq || action == "dec") && self.respond_to?(cache_setter)
            self.send cache_setter, count(field_name, true, owner, self)
          end
          # we need to save model to invalidate cache
          updated = self.save(validate: false)

          {track: current, updated: updated, uniq: uniq}
        end
        
      end 
      
      def count(field_name, uniq, owner, target, period = nil)
        scope = Track.where(tracker: field_name)
        scope = scope.where(owner_id: owner.id) unless owner == :all
        scope = scope.where(target_id: target.id, target_type: target.class.name) unless target == :all
        scope = scope.where("date_trunc('#{period}', created_at) = ?", 
        Time.now.utc.send("beginning_of_#{period}").to_s(:db)) unless period.nil?
        if uniq
          scope.sum(:value, :group => :ip).delete_if{|k,v| v == 0}.keys.count
        else
          scope.sum(:value)
        end
        
      end 
      
      def calculate(current, action, value)  
        case action
        when "inc"
          current = current + value
        when "dec"
          current = current - value
        when "set"
          current = value
        end
        [0,current].max
      end

    end
  end
end
