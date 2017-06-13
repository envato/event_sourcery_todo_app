module RequestHelpers
  def app
    @@app ||= EventSourceryTodoApp::Server
  end
end
