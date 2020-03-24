# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in hackerone-client.gemspec
gemspec

group :developement do
  gem "pry"
end

group :test do
  gem "rubocop"
  gem "rubocop-github"
  gem "rubocop-performance"
end

group :guard do
  gem "growl", require: RUBY_PLATFORM.include?("darwin") && "growl"
  gem "guard-rspec"
  gem "rb-fsevent", require: RUBY_PLATFORM.include?("darwin") && "rb-fsevent"
end
