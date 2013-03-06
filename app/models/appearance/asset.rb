require "yui/compressor"

class Appearance::Asset < ActiveRecord::Base

  class AssetStringIO < StringIO
    attr_accessor :filepath

    def initialize(*args)
      super(*args[1..-1])
      @filepath = args[0]
    end

    def original_filename
      File.basename(filepath)
    end
  end

  VALID_TYPES = {css: "text/css", js: "application/javascript"}
  
  attr_accessible :body, :content_type, :filename
  
  attr_accessor :compressed_body
  
  validates :filename, :body, :content_type, presence: true
  validates_uniqueness_of :filename, scope: :content_type
  validates_inclusion_of :content_type, :in => VALID_TYPES.values
  
  after_save :compile
  before_destroy :unlink
  
  scope :js, where(content_type: VALID_TYPES[:js])
  scope :css, where(content_type: VALID_TYPES[:css])  
  
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
    if storage == "fog"
      "//storage.googleapis.com/#{ENV['FOG_DIRECTORY']}/#{file_path}"
    else
      "/theme_assets/#{filename}"
    end
  end

  def value
    if storage == "fog"
      @value ||= begin
        uploader.retrieve_from_store!(filename)
        uploader.file.read
      end
    else
      File.open(file_path, "r").read
    end
  end

  def exists?
    if storage == "fog"
      @exists ||= begin
        uploader.retrieve_from_store!(filename)
        uploader.file.exists?
      end
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
    if storage == "fog"
      # file = Tempfile.new(filename)
      # begin
      #   file.write(compressed_body)
      #   uploader.store!(file)
      # ensure
      #   file.close
      #   file.unlink
      # end   
      uploader.store!(AssetStringIO.new(filename, compressed_body))
    else
      Dir.mkdir(asset_path) unless File.directory?(asset_path)
      File.open(file_path, "w+") { |f| f.write(compressed_body) }
    end
  end

  def unlink
    if storage == "fog"
      uploader.retrieve_from_store!(filename)
      uploader.remove!
    else
      File.unlink(file_path)
    end
  end

  def file_path
    "#{asset_path}/#{filename}"
  end

  def storage
    @storage ||= Settings.assets["storage"]
  end

  def asset_path
    @asset_path ||= storage == "fog" ? "theme_assets" : "#{Rails.root}/public/theme_assets"
  end  

  def uploader
    @uploader ||= AssetUploader.new
  end

end
