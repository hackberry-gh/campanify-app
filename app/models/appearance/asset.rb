require "yui/compressor"
require "aws/s3"

class Appearance::Asset < ActiveRecord::Base
  VALID_TYPES = {css: "text/css", js: "application/javascript"}
  
  attr_accessible :body, :content_type, :filename
  
  attr_accessor :compressed_body
  
  validates :filename, :body, :content_type, presence: true
  validates_uniqueness_of :filename, scope: :content_type
  validates_inclusion_of :content_type, :in => VALID_TYPES.values
  
  after_save :compile
  before_destroy :unlink
  
  @@host_type   = Settings.assets["host_type"]
  cattr_reader :host_type
  
  @@asset_path  = "#{Rails.root}/public/assets"
  cattr_reader :asset_path
  
  @@s3_bucket   = ENV["AWS_S3_BUCKET"]
  @@s3_key      = ENV["AWS_S3_KEY"]
  @@s3_secret   = ENV["AWS_S3_SECRET"]

  def compile
    case content_type
    when VALID_TYPES[:css]
      compile_css
    when VALID_TYPES[:js]
      compile_js
    end
    upload  
  end

  def url
    if @@host_type=="s3"
      "http://s3.amazonaws.com/#{@@s3_bucket}/#{filename}"
    else
      "/assets/#{filename}"
    end
  end

  def value
    if @@host_type=="s3"
      AWS::S3::S3Object.find(filename, @@s3_bucket).value
    else
      File.open("#{Rails.root}/public/assets/#{self.filename}", "r").read
    end
  end

  def exists?
    if @@host_type=="s3"
      AWS::S3::S3Object.exists? filename, @@s3_bucket
    else
      File.exists?(file_path)
    end
  end

  private

  def compile_css
    compressor = YUI::CssCompressor.new
    self.compressed_body = compressor.compress body
  end

  def compile_js
    compressor = YUI::JavaScriptCompressor.new(:munge => true)
    self.compressed_body = compressor.compress body    
  end

  def upload
    if @@host_type=="s3"
      AWS::S3::Base.establish_connection!(
      :access_key_id     => @@s3_key, 
      :secret_access_key => @@s3_secret
      )
      AWS::S3::S3Object.store(filename, self.compressed_body, @@s3_bucket, 
      content_type: content_type, access: :public_read)
    else
      Dir.mkdir(self.class.asset_path) unless File.directory?(self.class.asset_path)
      File.open(file_path, "w+") { |f| f.write(compressed_body) }
    end
  end

  def unlink
    if @@host_type=="s3"
      AWS::S3::S3Object.delete(filename, @@s3_bucket)
    else
      File.unlink(file_path)
    end
  end

  def file_path
    "#{self.class.asset_path}/#{filename}"
  end
end
