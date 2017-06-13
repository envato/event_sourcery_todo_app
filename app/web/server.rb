require 'sinatra'

require 'app/commands/todo/add'
require 'app/projections/outstanding/query'

module EventSourceryTodoApp
  class Server < Sinatra::Base
    error UnprocessableEntity do |error|
      body "Unprocessable Entity: #{error.message}"
      status 422
    end

    error BadRequest do |error|
      body "Bad Request: #{error.message}"
      status 400
    end

    post '/todo/:todo_id' do
      command = Commands::Todo::Add::Command.new(params)
      command.valid?
      Commands::Todo::Add::CommandHandler.handle(command)
      status 201
    end

    get '/todos/outstanding' do
      body JSON.pretty_generate(
        EventSourceryTodoApp::Projections::Outstanding::Query.handle
      )
      status 200
    end
  end
end
