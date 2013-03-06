class CsvImport < ActiveRecord::Base
  attr_accessible :filename, :results, :uniq_field, :model, :file
  attr_accessor :file, :uniq_field, :model

  validates_presence_of :model

  validates_presence_of :filename, :if => "file.nil?"
  validates_presence_of :file, :if => "filename.blank?"
  
  before_create :upload

  after_create :import

  private

  def upload
  	uploader = CsvUploader.new
    uploader.store!(file)
    self.filename = uploader.file.filename
  end

  def import
  	Campanify::CSVImporter.delay.import(self.filename, model.constantize, uniq_field ? uniq_field.to_sym : nil)
  end

end
