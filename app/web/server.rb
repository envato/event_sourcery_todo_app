require 'sinatra'

module EventSourceryTodoApp
  class Server < Sinatra::Base
    post '/todo/:todo_id' do
      status 201
    end
  end
end
