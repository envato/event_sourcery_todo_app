$LOAD_PATH.unshift '.'

task :environment do
  require 'config/environment'
end

desc "Loads the project and starts Pry"
task console: :environment do
  require 'pry'
  Pry.start
end

desc 'Run Event Stream Processors'
task run_processors: :environment do
  puts "Starting Event Stream processors"

  event_source = EventSourceryTodoApp.event_source
  tracker = EventSourceryTodoApp.tracker
  db_connection = EventSourceryTodoApp.projections_database

  # Need to disconnect before starting the processors so
  # that the forked processes have their own connection / fork safety.
  db_connection.disconnect

  # Show our ESP logs immediately under Foreman
  $stdout.sync = true

  processors = [
    EventSourceryTodoApp::Projections::CompletedTodos::Projector.new(
      tracker: tracker,
      db_connection: db_connection,
    ),
    EventSourceryTodoApp::Projections::OutstandingTodos::Projector.new(
      tracker: tracker,
      db_connection: db_connection,
    ),
    EventSourceryTodoApp::Projections::ScheduledTodos::Projector.new(
      tracker: tracker,
      db_connection: db_connection,
    ),
    EventSourceryTodoApp::Reactors::TodoCompletedNotifier.new(
      tracker: tracker,
      db_connection: db_connection,
    )
  ]

  # The ESPRunner will fork child processes for each of the ESPs passed to it.
  EventSourcery::EventProcessing::ESPRunner.new(
    event_processors: processors,
    event_source: event_source,
  ).start!
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

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
end
