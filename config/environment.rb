require 'event_sourcery'
require 'event_sourcery/postgres'

require 'app/utils'
require 'app/events/todo_abandoned'
require 'app/events/todo_added'
require 'app/events/todo_amended'
require 'app/events/todo_completed'
require 'app/events/stakeholder_notified_of_todo_completion'
require 'app/errors'
require 'app/projections/completed_todos/projector'
require 'app/projections/outstanding_todos/projector'
require 'app/projections/scheduled_todos/projector'
require 'app/reactors/todo_completed_notifier'

# Configure EventSourcery and our Postgres event store.

module EventSourceryTodoApp
  class Config
    attr_accessor :database_url
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end

  def self.environment
    ENV.fetch('RACK_ENV', 'development')
  end

  def self.event_store
    EventSourcery::Postgres.config.event_store
  end

  def self.event_source
    EventSourcery::Postgres.config.event_store
  end

  def self.tracker
    EventSourcery::Postgres.config.event_tracker
  end

  def self.event_sink
    EventSourcery::Postgres.config.event_sink
  end

  def self.projections_database
    EventSourcery::Postgres.config.projections_database
  end

  def self.repository
    @repository ||= EventSourcery::Repository.new(
      event_source: event_source,
      event_sink: event_sink
    )
  end
end

EventSourceryTodoApp.configure do |config|
  postgres_port = ENV['BOXEN_POSTGRESQL_PORT'] || 5432
  config.database_url = ENV['DATABASE_URL'] || "postgres://127.0.0.1:#{postgres_port}/event_sourcery_todo_app_#{EventSourceryTodoApp.environment}"
end

EventSourcery::Postgres.configure do |config|
  database = Sequel.connect(EventSourceryTodoApp.config.database_url)

  # NOTE: Often we choose to split our events and projections into separate
  # databases. For the purposes of this example we'll use one.
  config.event_store_database = database
  config.projections_database = database
end
