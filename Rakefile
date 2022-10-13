$LOAD_PATH.unshift '.'

# Create our application's ESPs
def processors(db_connection, tracker)
  [
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
    ),
    EventSourceryTodoApp::Reactors::MovedupTodos::Projector.new(
      tracker: tracker,
      db_connection: db_connection,
    )
  ]
end

task :environment do
  require 'config/environment'
end

desc "Loads the project and starts Pry"
task console: :environment do
  require 'pry'
  Pry.start
end


desc 'Setup Event Stream Processors'
task setup_processors: :environment do
  puts "Setting up Event Stream processors"

  processors(EventSourceryTodoApp.projections_database, EventSourceryTodoApp.tracker).each(&:setup)
end

desc 'Run Event Stream Processors'
task run_processors: :environment do
  puts "Starting Event Stream processors"

  # Need to disconnect before starting the processors so
  # that the forked processes have their own connection / fork safety.
  EventSourceryTodoApp.projections_database.disconnect

  # Show our ESP logs immediately under Foreman
  $stdout.sync = true

  esps = processors(EventSourceryTodoApp.projections_database, EventSourceryTodoApp.tracker)

  # The ESPRunner will fork child processes for each of the ESPs passed to it.
  EventSourcery::EventProcessing::ESPRunner.new(
    event_processors: esps,
    event_source: EventSourceryTodoApp.event_source,
  ).start!
end

namespace :db do
  desc 'Create database'
  task create: :environment do
    url = EventSourceryTodoApp.config.database_url
    database_name = File.basename(url)
    database = Sequel.connect URI.join(url, '/template1').to_s
    database.run(<<~DB_QUERY)
      CREATE DATABASE #{database_name};
    DB_QUERY

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
