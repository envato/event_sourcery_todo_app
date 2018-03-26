module EventSourceryTodoApp
  class Aggregate
    include Eventory::EventHandler

    def initialize(id, events)
      @id = id.to_str
      # @version = 0
      # @on_unknown_event = on_unknown_event
      @changes = []
      load_history(events)
    end

    private

    attr_reader :id

    def load_history(events)
      events.each(&method(:handle))
    end

    def apply_event(event_class, options = {})
      event = event_class.new(**options.merge(aggregate_id: id))
      handle(event)
      @changes << event
    end

    def handle_event(recorded_event)
      # @_current_event = recorded_event
      event = recorded_event.data
      self.class.event_handlers[event.class].each do |handler|
        instance_exec(event, &handler)
      end
    # ensure
    #   @_current_event = nil
    end
  end
end
