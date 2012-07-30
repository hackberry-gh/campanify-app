# i18
require 'i18n/backend/active_record'
I18n::Backend::ActiveRecord::Implementation.class_eval do
  protected
  def lookup(locale, key, scope = [], options = {})
    key = normalize_flat_keys(locale, key, scope, options[:separator])
    result = Translation.locale(locale).lookup(key).all

    if result.empty?
      nil
    elsif result.first.key == key
      result.first.value
    else
      # chop_range = (key.size + FLATTEN_SEPARATOR.size)..-1
      # result = result.inject({}) do |hash, r|
      #   hash[r.key.slice(chop_range)] = r.value
      #   hash
      # end
      # result.deep_symbolize_keys
      chop_range = (key.size + ".".size)..-1                                
      result = result.inject({}) do |hash, r|
        choped_key = r.key.slice(chop_range)
        unless choped_key.include?(".")
          hash[choped_key] = r.value
        else
          sub_keys = choped_key.split(".")
          sub_key = sub_keys.first
          hash[sub_key] = lookup(locale, sub_key, key, options)
        end
        hash
      end
      result.deep_symbolize_keys      
    end

  rescue ::ActiveRecord::StatementInvalid
    # is the translations table missing?
    nil
  end
end
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::ActiveRecord::Missing)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)
I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Cache)
I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new)

I18n.class_eval do
  def self.available_locales
    Settings.i18n['available_locales'].map(&:to_sym)
  end
  def self.completed_locales
    Settings.i18n['completed_locales'].map(&:to_sym)
  end
end