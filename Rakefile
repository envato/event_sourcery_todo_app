$LOAD_PATH.unshift '.'

task :environment do
  require 'config/environment'
end

namespace :db do
  desc 'Create database'
  task create: :environment do
    url = EventSourceryTodoApp.config.database_url
    database_name = File.basename(url)
    database = Sequel.connect URI.join(url, '/template1').to_s
    database.run("CREATE DATABASE #{database_name}")
    database.disconnect
  end

  desc 'Drop database'
  task drop: :environment do
    url = EventSourceryTodoApp.config.database_url
    database_name = File.basename(url)
    database = Sequel.connect URI.join(url, '/template1').to_s
    database.run("DROP DATABASE IF EXISTS #{database_name}")
    database.disconnect
  end

  desc 'Migrate database'
  task migrate: :environment do
    database = EventSourcery::Postgres.config.event_store_database
    EventSourcery::Postgres::Schema.create_event_store(db: database)
  end
end
