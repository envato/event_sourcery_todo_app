module EventSourceryTodoApp
  module Aggregates
    class Todo
      include EventSourcery::AggregateRoot

      apply TodoAdded do |event|
        @added = true
      end

      apply TodoAmended do |event|
      end

      apply TodoCompleted do |event|
        @completed = true
      end

      def add(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} already exists" if added

        apply_event(TodoAdded,
          aggregate_id: id,
          body: payload,
        )
      end

      def amend(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} does not exist" unless added
        raise UnprocessableEntity, "Todo #{id.inspect} is complete" if completed

        apply_event(TodoAmended,
          aggregate_id: id,
          body: payload,
        )
      end

      def complete(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} does not exist" unless added
        raise UnprocessableEntity, "Todo #{id.inspect} already complete" if completed

        apply_event(TodoCompleted,
          aggregate_id: id,
          body: payload,
        )
      end

      private

      attr_reader :added, :completed
    end
  end
end
