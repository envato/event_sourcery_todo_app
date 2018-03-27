require 'json'

module RequestHelpers
  def app
    @@app ||= EventSourceryTodoApp::Server
  end

  def last_event(aggregate_id)
    EventSourceryTodoApp.event_store
      .read_stream_events(aggregate_id)
      .last
      .data
  end

  def post_json(uri, body_hash={})
    post(uri, body_hash.to_json, {"CONTENT_TYPE" => "application/json"})
  end

  def put_json(uri, body_hash={})
    put(uri, body_hash.to_json, {"CONTENT_TYPE" => "application/json"})
  end
end
