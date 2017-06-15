require 'sinatra'
require 'json'

require 'app/commands/todo/abandon'
require 'app/commands/todo/add'
require 'app/commands/todo/amend'
require 'app/commands/todo/complete'
require 'app/projections/completed_todos/query'
require 'app/projections/outstanding_todos/query'
require 'app/projections/scheduled_todos/query'

module EventSourceryTodoApp
  class Server < Sinatra::Base
    # Ensure our error handlers are triggered in development
    set :show_exceptions, :after_handler

    configure :development do
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = __dir__
    end

    error UnprocessableEntity do |error|
      body "Unprocessable Entity: #{error.message}"
      status 422
    end

    error BadRequest do |error|
      body "Bad Request: #{error.message}"
      status 400
    end

    before do
      content_type :json
    end

    def json_params
      # Coerce this into a symbolised Hash so Sintra data structures don't leak into
      # the command layer
      Hash[
        params.merge(
          JSON.parse(request.body.read)
        ).map{ |k, v| [k.to_sym, v] }
      ]
    end

    post '/todo/:todo_id' do
      command = Commands::Todo::Add::Command.new(json_params)
      command.valid?
      Commands::Todo::Add::CommandHandler.new.handle(command)
      status 201
    end

    put '/todo/:todo_id' do
      command = Commands::Todo::Amend::Command.new(json_params)
      command.valid?
      Commands::Todo::Amend::CommandHandler.new.handle(command)
      status 200
    end

    post '/todo/:todo_id/complete' do
      command = Commands::Todo::Complete::Command.new(json_params)
      command.valid?
      Commands::Todo::Complete::CommandHandler.new.handle(command)
      status 200
    end

    post '/todo/:todo_id/abandon' do
      command = Commands::Todo::Abandon::Command.new(json_params)
      command.valid?
      Commands::Todo::Abandon::CommandHandler.new.handle(command)
      status 200
    end

    get '/todos/outstanding' do
      body JSON.pretty_generate(
        EventSourceryTodoApp::Projections::Outstanding::Query.handle
      )
      status 200
    end

    get '/todos/scheduled' do
      body JSON.pretty_generate(
        EventSourceryTodoApp::Projections::Scheduled::Query.handle
      )
      status 200
    end

    get '/todos/completed' do
      body JSON.pretty_generate(
        EventSourceryTodoApp::Projections::CompletedTodos::Query.handle
      )
      status 200
    end
  end
end
