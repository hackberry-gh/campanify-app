require 'csv'
module Campanify
  class CSVImporter

    def self.import(filename, klass, uniq_field = nil)
      new.import(filename, klass, uniq_field)
    end

    def import(filename, klass, uniq_field = nil)

      csv_import = CsvImport.find_or_create_by_filename(filename)

      options = {
        :headers => true,
        :header_converters => :symbol,
        :col_sep => ','
      }

      uploader = CsvUploader.new
      uploader.retrieve_from_store!(filename)

      results = []

      begin
        i = 0
        ::CSV.parse(uploader.file.read, options) do |row|
          attributes = row.to_hash
          if uniq_field
            model = klass.send(:"find_or_initialize_by_#{uniq_field}", attributes.delete(uniq_field))
            model.meta[:csv_file] = filename if model.respond_to?(:meta)
            model.assign_attributes(attributes)
          else
            model = klass.new(attributes)
          end
          status = model.new_record? ? "created" : "updated"
          if model.save
            results << "#{i}: #{status}"
          else
            results << "#{i}: #{model.errors.full_messages.join(", ")}"
          end
          i += 1
        end
      rescue CSV::MalformedCSVError
        results = {error: "Malformed CSV file"}
      end

      csv_import.update_attribute(:results, results)

      results

    end

  end
end
