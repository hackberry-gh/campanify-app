module Campanify
  module Models
    module History

      extend ActiveSupport::Concern

      module ClassMethods
        def track(*args)
          args.each do |field_name|
            class_eval <<-CODE

            def inc_#{field_name}(owner = self)
              update_historical_field("#{field_name}", "inc", 1, owner)
            end
            def dec_#{field_name}(owner = self)
              update_historical_field("#{field_name}", "inc", -1, owner)
            end     
            def set_#{field_name}(value, owner = self)
              update_historical_field("#{field_name}", "set", value, owner)
            end

            def total_#{field_name}(uniq = true, owner = self)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}'][owner.id]
                values = tracks.values.map{|h| h.values}.flatten.map{|h| h.values}.flatten.map{|h| h.values}.flatten if tracks
                tracks_count values, uniq if tracks
              else
                0
              end
            end
            
            def yearly_#{field_name}(uniq = true, owner = self, year = Time.now.year)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}'][owner.id][year]
                tracks_count tracks.values.first.values.first.values, uniq if tracks
              else
                0
              end
            end
            def monthly_#{field_name}(uniq = true, owner = self, month = Time.now.month, year = Time.now.year)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}'][owner.id][year][month]
                tracks_count  tracks.values.first.values, uniq if tracks
              else
                0
              end
            end
            def daily_#{field_name}(uniq = true, owner = self, day = Time.now.day, month = Time.now.month, year = Time.now.year)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}'][owner.id][year][month][day]
                tracks_count  tracks.values, uniq if tracks
              else
                0
              end                
            end
            def hourly_#{field_name}(uniq = true, owner = self, hour = Time.now.hour, day = Time.now.day, month = Time.now.month, year = Time.now.year)
              unless self['#{field_name}'].empty?              
                tracks = self['#{field_name}'][owner.id][year][month][day][hour]
                tracks_count  tracks.values, uniq if tracks
              else
                0
              end              
            end                

            CODE
          end
        end
      end

      included do
        include Campanify::ThreadedAttributes
        threaded :ip
      end

      private

      def update_historical_field(field_name, action, value, owner)
        
        if current_ip && owner
          
          year, month, day, hour = time_stamp.split(".").map(&:to_i)
          
          begin
            current_value = self.send(field_name.to_sym)[owner.id][year][month][day][hour][ip_stamp] || 0
          rescue NoMethodError => e
            current_value = 0
          end
          
          case action
          when "inc"
            value = current_value + value
          when "dec"
            value = current_value - value            
          when "set"
            value = value            
          end
          self.send(field_name.to_sym)[owner.id] = {} unless self.send(field_name.to_sym)[owner.id]
          self.send(field_name.to_sym)[owner.id][year] = {} unless self.send(field_name.to_sym)[owner.id][year]          
          self.send(field_name.to_sym)[owner.id][year][month] = {} unless self.send(field_name.to_sym)[owner.id][year][month]                    
          self.send(field_name.to_sym)[owner.id][year][month][day] = {} unless self.send(field_name.to_sym)[owner.id][year][month][day]
          self.send(field_name.to_sym)[owner.id][year][month][day][hour] = {} unless self.send(field_name.to_sym)[owner.id][year][month][day][hour]
          self.send(field_name.to_sym)[owner.id][year][month][day][hour][ip_stamp] = value 
          self.save!(validate: false)
        end
      end          

      # def generate_key(field_name, owner)
      #   "#{field_name}.#{owner.id}.#{time_stamp}.#{ip_stamp}"
      # end    

      def time_stamp
        t = Time.now
        "#{t.year}.#{t.month}.#{t.day}.#{t.hour}"
        # Time.now.to_key
      end

      def ip_stamp
        current_ip.parameterize.underscore
      end

      def tracks_count(tracks, uniq = true)
        if uniq
          if tracks.is_a?(Array)
            tracks.delete_if{|h| h.values.first == 0}.
            map{|h| h.keys}.
            flatten.uniq.size
          elsif tracks.is_a?(Hash)
            tracks.delete_if{|k,v| v == 0}.
            keys.flatten.uniq.size
          end
        else
          if tracks.is_a?(Array)
            tracks.sum{|h| 
              h.is_a?(Fixnum) ? h :
              h.values.first
            }
          elsif tracks.is_a?(Hash)
            tracks.values.sum
          end

        end
      end

    end
  end
end