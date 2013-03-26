class CsvImport < ActiveRecord::Base
  attr_accessible :filename, :results, :uniq_field, :model, :file, :validate
  attr_accessor :file, :uniq_field, :model, :validate

  validates_presence_of :model

  validates_presence_of :filename, :if => "file.nil?"
  validates_presence_of :file, :if => "filename.blank?"

  validates_uniqueness_of :filename, allow_nil: true, allow_blank: true
  
  before_create :upload

  after_create :import

  def validate?
    self.validate.to_bool
  end

  private

  def upload
    uploader = CsvUploader.new
    uploader.store!(file)
    self.filename = uploader.file.filename
  end

  def import
    puts "is validating? #{self.validate.inspect}"
    Delayed::Job.enqueue(Jobs::CSVImporterJob.new(self.filename, model.constantize, uniq_field.present? ? uniq_field.to_sym : nil, self.validate?))
  end

end
