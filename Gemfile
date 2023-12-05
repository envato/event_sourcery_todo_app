# frozen_string_literal: true

source 'https://rubygems.org'

gem 'event_sourcery'
gem 'event_sourcery-postgres'

gem 'rake'
gem 'sinatra'
gem 'puma'
# NOTE: pg is an implicit dependency of event_sourcery-postgres but we need to
# lock to an older version for deprecation warnings.
gem 'pg', '1.5.4'

group :development, :test do
  gem 'pry-byebug'
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'shotgun', git: 'https://github.com/delonnewman/shotgun.git'
  gem 'commander'
  gem 'better_errors'
end
