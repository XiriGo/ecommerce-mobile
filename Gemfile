source "https://rubygems.org"

gem "fastlane", "~> 2.225"

# Load platform-specific plugins
["ios", "android"].each do |platform|
  plugins_path = File.join(File.dirname(__FILE__), platform, "fastlane", "Pluginfile")
  eval_gemfile(plugins_path) if File.exist?(plugins_path)
end
