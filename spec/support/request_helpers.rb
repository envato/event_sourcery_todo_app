module RequestHelpers
  def app
    @@app ||= EventSourceryTodoApp::Server
  end

  def last_event(aggregate_id)
    EventSourceryTodoApp.event_store
      .get_events_for_aggregate_id(aggregate_id).last
  end
end
