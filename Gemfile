source 'https://rubygems.org'

# Specify your gem's dependencies in hackerone-client.gemspec
gemspec

group :guard do
  gem "pry"
  gem "growl", :require => RUBY_PLATFORM.include?('darwin') && 'growl'
  gem "rb-fsevent", :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem "guard-rspec"
end
