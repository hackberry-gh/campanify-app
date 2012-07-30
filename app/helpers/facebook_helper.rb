module FacebookHelper
	def oauth(callback_url)
		@oauth ||= ::Koala::Facebook::OAuth.new(Settings.facebook['app_id'], Settings.facebook['app_secret'], callback_url)
	end
	def graph(oauth_access_token)
		@graph ||= ::Koala::Facebook::API.new(oauth_access_token)
	end
end