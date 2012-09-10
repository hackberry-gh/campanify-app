module FacebookHelper
	def oauth(callback_url)
		@oauth ||= ::Koala::Facebook::OAuth.new(Settings.facebook['app_id'], Settings.facebook['app_secret'], callback_url)
	end
	def graph(oauth_access_token)
		@graph ||= ::Koala::Facebook::API.new(oauth_access_token)
	end
	def fb_locales
	  @fb_locales = _cache "facebook_locales" do
      locales = ::Ox.parse(File.read("#{Rails.root}/db/facebook_locale.xml"))
      locales.nodes[0].nodes.map{ |n| n.nodes[1].nodes[0].nodes[0].nodes[1].nodes[0] }
    end
  end
	def fb_locale(locale)
    fb_locales.delete_if{|l| l.split("_").first != locale.to_s}.first ||
    fb_locales.delete_if{|l| l.split("_").first != I18n.default_locale.to_s}.first ||
    "en_US"
  end
end