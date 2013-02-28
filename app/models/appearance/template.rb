class Appearance::Template < ActiveRecord::Base
  include Campanify::Cache  
  class Resolver < ActionView::Resolver 
  
    include Singleton
    include Campanify::Cache
    include Campanify::ActiveWidget

    protected

    def find_templates(name, prefix, partial, details)
      conditions = {
        :path => normalize_path(name, prefix),
        :locale => normalize_array(details[:locale]), 
        :format => normalize_array(details[:formats]), 
        :handler => normalize_array(details[:handlers]), 
        :partial => partial || false
      }
      templates = _cache Appearance::Template::Resolver, conditions.values do
        templates = Appearance::Template.where(conditions).all
      end
      templates.map do |record| 
        initialize_template(record)
      end
    end

    # Normalize name and prefix, so the tuple ["index", "users"] becomes # "users/index" and the tuple ["template", nil] becomes "template". 
    def normalize_path(name, prefix)
      prefix.present? ? "#{prefix}/#{name}" : name
    end

    # Normalize arrays by converting all symbols to strings.
    def normalize_array(array) 
      array.map(&:to_s)
    end

    # Initialize an ActionView::Template object based on the record found.
    def initialize_template(record)
      source = record.body
      identifier = "Appearance::Template - #{record.id} - #{record.path.inspect}"
      handler = ActionView::Template.registered_template_handler(record.handler)
      details = {
        :format => Mime[record.format],
        :updated_at => record.updated_at,
        :virtual_path => virtual_path(record.path, record.partial)
      }

      # add widgets into render list from template's body
      add_widgets_into_asset_render_list(record)

      ActionView::Template.new(source, identifier, handler, details)
    end
    
    # Make paths as "users/user" become "users/_user" for partials.
    def virtual_path(path, partial) 
      return path unless partial
      if index = path.rindex("/")
        path.insert(index + 1, "_")
      else
        "_#{path}"
      end 
    end
      
  end
  
  attr_accessible :body, :format, :handler, :locale, :partial, :path
  
  validates :body, :path, presence: true
  validates :format,  :inclusion => Mime::SET.symbols.map(&:to_s)
  validates :locale,  :inclusion => I18n.available_locales.map(&:to_s)
  validates :handler, inclusion: ActionView::Template::Handlers.extensions.map(&:to_s)
  
  after_save :clear_cache

  scope :partials, where(partial: true)
  
  private
  
  def clear_cache
    Resolver.instance.clear_cache
    _expire_cache Appearance::Template::Resolver, self.path, self.locale, self.format, self.handler, self.partial
  end
end
