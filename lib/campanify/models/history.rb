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

            def total_#{field_name}(uniq = true, owner = :all)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}']
                values = tracks.values.map{|h| h.values}.flatten.map{|h| h.values}.flatten.map{|h| h.values}.flatten if tracks
                tracks_count values, uniq, owner if tracks
              else
                0
              end
            end
            def yearly_#{field_name}(uniq = true, owner = :all, year = Time.now.year)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}'][year]
                tracks_count tracks.values.first.values.first.values, uniq, owner if tracks
              else
                0
              end
            end
            def monthly_#{field_name}(uniq = true, owner = :all, month = Time.now.month, year = Time.now.year)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}'][year][month]
                tracks_count  tracks.values.first.values, uniq, owner if tracks
              else
                0
              end
            end
            def daily_#{field_name}(uniq = true, owner = :all, day = Time.now.day, month = Time.now.month, year = Time.now.year)
              unless self['#{field_name}'].empty?
                tracks = self['#{field_name}'][year][month][day]
                tracks_count  tracks.values, uniq, owner if tracks
              else
                0
              end                
            end
            def hourly_#{field_name}(uniq = true, owner = :all, hour = Time.now.hour, day = Time.now.day, month = Time.now.month, year = Time.now.year)
              unless self['#{field_name}'].empty?              
                tracks = self['#{field_name}'][year][month][day][hour]
                tracks_count  tracks, uniq, owner if tracks
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
            current_value = self.send(field_name.to_sym)[year][month][day][hour][uniq_stamp(owner)] || 0
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
          self.send(field_name.to_sym)[year] = {} unless self.send(field_name.to_sym)[year]          
          self.send(field_name.to_sym)[year][month] = {} unless self.send(field_name.to_sym)[year][month]                    
          self.send(field_name.to_sym)[year][month][day] = {} unless self.send(field_name.to_sym)[year][month][day]
          self.send(field_name.to_sym)[year][month][day][hour] = {} unless self.send(field_name.to_sym)[year][month][day][hour]
          self.send(field_name.to_sym)[year][month][day][hour][uniq_stamp(owner)] = value 
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

      def uniq_stamp(owner)
        "#{owner.id}_#{current_ip}"
      end

      def tracks_count(tracks, uniq = true, owner = :all)
        # puts "OWNER #{owner} #{owner.class}"
        # tracks = tracks.clone
        if uniq
          if tracks.is_a?(Array)
            tracks.delete_if{|h| h.values.first == 0}.
            map{|h| h.keys}.
            flatten.uniq.
            # delete_if{ |s| owner != :all && owner != s.split(".").first.to_i }.
            size
          elsif tracks.is_a?(Hash)
            tracks.delete_if{|k,v| v == 0}.
            keys.flatten.uniq.
            # delete_if{ |s| owner != :all && owner != s.split(".").first.to_i }.
            size
          end
        else
          if tracks.is_a?(Array)
            # puts "ARRAY #{tracks}"
            tracks.sum{|h| 
              # h.delete_if{ |k,v| owner != :all && owner != k.split(".").first.to_i }.values.sum
              h.values.sum
            }
          elsif tracks.is_a?(Hash)
            # puts "HASH #{tracks}"            
            # tracks.delete_if{ |k,v| owner != :all && owner != k.split(".").first.to_i }.sum
            tracks.values.sum
          end

        end
      end

    end
  end
end