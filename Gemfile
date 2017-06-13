source 'https://rubygems.org'

source 'https://rubygems.envato.com' do
  gem 'event_sourcery'
  gem 'event_sourcery-postgres'
end

gem 'rake'
gem 'sinatra'
# NOTE: pg is an implicit dependency of event_sourcery-postgres but we need to
# lock to an older version for deprecation warnings.
gem 'pg', '0.20.0'

group :development, :test do
  gem 'pry'
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'
end
