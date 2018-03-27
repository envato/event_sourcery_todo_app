module EventSourceryTodoApp
  class Repository
    def initialize(event_store:)
      @event_store = event_store
    end

    def load(type, stream_id)
      events = event_store.read_stream_events(stream_id)
      type.new(stream_id, events)
    end

    def save(aggregate)
      new_events = aggregate.changes
      if new_events.any?
        event_store.append(
          new_events.first.stream_id, 
          new_events,
          expected_version: aggregate.version - new_events.count
        )
      end
      aggregate.clear_changes
    end

    private

    attr_reader :event_store
  end
end
