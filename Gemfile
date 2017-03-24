source 'https://rubygems.org'

# Specify your gem's dependencies in hackerone-client.gemspec
gemspec

group :developement do
  gem "pry"
end

group :guard do
  gem "growl", :require => RUBY_PLATFORM.include?('darwin') && 'growl'
  gem "rb-fsevent", :require => RUBY_PLATFORM.include?('darwin') && 'rb-fsevent'
  gem "guard-rspec"
end
