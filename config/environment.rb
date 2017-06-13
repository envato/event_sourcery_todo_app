require 'event_sourcery'
require 'event_sourcery/postgres'

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
end

EventSourceryTodoApp.configure do |config|
  config.database_url = "postgres://127.0.0.1:5432/event_sourcery_todo_app_#{EventSourceryTodoApp.environment}"
end

EventSourcery::Postgres.configure do |config|
  database = Sequel.connect(EventSourceryTodoApp.config.database_url)

  # NOTE: Often we choose to split our events and projections into separate
  # databases. For the purposes of this example we'll use one.
  config.event_store_database = database
  config.projections_database = database
end
