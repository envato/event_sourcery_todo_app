module EventSourceryTodoApp
  module Aggregates
    class Todo
      include EventSourcery::AggregateRoot

      apply TodoAdded do |event|
      end

      def add(payload)
        apply_event(TodoAdded,
          aggregate_id: id,
          body: payload,
        )
      end
    end
  end
end
