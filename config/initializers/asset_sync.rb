AssetSync.configure do |config|
	config.enabled = ENV['FOG_DIRECTORY'] != 'campanify-app-campanify-demo'
end