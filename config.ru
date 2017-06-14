$LOAD_PATH << '.'

require 'config/environment'
require 'app/web/server'

run EventSourceryTodoApp::Server.new
