module EventSourceryTodoApp
  module Aggregates
    class TodoList
      include EventSourcery::AggregateRoot

      apply TodoListCreated do |event|
        # We track the ID when a todo is added so we can ensure the same todo isn't
        # added twice.
        #
        # We can save more attributes off the event in here as necessary.
        @aggregate_id = event.aggregate_id
      end

      def create(payload)
        apply_event(TodoListCreated,
          aggregate_id: id,
          body: payload,
        )
      end
    end
  end
end