module EventSourceryTodoApp
  class Aggregate
    include Eventory::EventHandler

    def initialize(id, events)
      @id = id.to_str
      # @version = 0
      # @on_unknown_event = on_unknown_event
      # @changes = []
      load_history(events)
    end

    private

    attr_reader :id

    def load_history(events)
      events.each(&method(:handle))
    end
  end
end
