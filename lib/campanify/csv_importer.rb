require "#{Rails.root}/app/uploaders/csv_uploader"
require 'csv'
module Campanify
  class CSVImporter

    def self.import(filename, klass, uniq_field = nil, validate = true)
      new.import(filename, klass, uniq_field, validate)
    end

    def import(filename, klass, uniq_field = nil, validate = true)

      csv_import = CsvImport.find_or_create_by_filename(filename)

      options = {
        :headers => true,
        :header_converters => :symbol,
        :col_sep => ','
      }

      uploader = CsvUploader.new
      uploader.retrieve_from_store!(filename)

      results = []

      i = 0
      begin
        ::CSV.parse(uploader.file.read, options) do |row|
          begin
            attributes = row.to_hash

            # if klass == "User"
              # Thread.current[:branch] = attributes[:country]
              # attributes[:meta_src] = attributes.delete(:src)
            # end

            protected_attributes = attributes.delete_if{|attr, val| !klass.accessible_attributes.include?(attr)}

            if uniq_field
              model = klass.send(:"find_or_initialize_by_#{uniq_field}", attributes.delete(uniq_field))
              model.meta[:csv_file] = filename if model.respond_to?(:meta)
              if klass == "User"
                model.meta[:src] = attributes[:src] if model.respond_to?(:meta)
                model.branch = attributes[:country] if model.respond_to?(:meta)
              end
              model.assign_attributes(attributes)
            else
              model = klass.new(attributes)
              model.meta[:csv_file] = filename if model.respond_to?(:meta)
              if klass == "User"
                model.meta[:src] = attributes[:src] if model.respond_to?(:meta)
                model.branch = attributes[:country] if model.respond_to?(:meta)
              end
            end
            protected_attributes.each{ |p_attr, val|
              model.send(:write_attribute, p_attr, val)
            }
            status = model.new_record? ? "created" : "updated"
            if model.save(validate: validate)
              # results << "#{i}: #{status}"
            else
              results << "#{i}: #{model.errors.full_messages.join(", ")}"
            end
            i += 1
          rescue Exception => e
            results << "ERROR: #{i}: #{e.inspect}"
            i += 1
          end
        end
      rescue CSV::MalformedCSVError => e
        results << "ERROR: #{i} Malformed CSV -> #{e.inspect}"
      end

      csv_import.update_attribute(:results, results)

      results

    end

  end
end
