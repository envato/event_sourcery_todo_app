require 'sinatra'

require 'app/commands/todo/add'

module EventSourceryTodoApp
  class Server < Sinatra::Base
    post '/todo/:todo_id' do
      command = Commands::Todo::Add::Command.new(params)
      command.valid?
      Commands::Todo::Add::CommandHandler.handle(command)
      status 201
    end
  end
end
