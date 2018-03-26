module EventSourceryTodoApp
  class Repository
    def initialize(event_store:)
      @event_store = event_store
    end

    def load(type, stream_id)
      events = event_store.read_stream_events(stream_id)
      type.new(stream_id, events)
    end

    private

    attr_reader :event_store
  end
end
