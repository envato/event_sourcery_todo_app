module EventSourceryTodoApp
  module Aggregates
    class Todo
      include EventSourcery::AggregateRoot

      apply TodoAdded do |event|
        @added = true
      end

      def add(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} already exists" if added

        apply_event(TodoAdded,
          aggregate_id: id,
          body: payload,
        )
      end

      private

      attr_reader :added
    end
  end
end
