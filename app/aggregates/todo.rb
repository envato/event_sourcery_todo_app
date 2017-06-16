module EventSourceryTodoApp
  module Aggregates
    class Todo
      include EventSourcery::AggregateRoot

      # These apply methods are the hook that this aggregate uses to update
      # its internal state from events.

      apply TodoAdded do |event|
        # We track the ID when a todo is added so we can ensure the same todo isn't
        # added twice.
        #
        # We can save more attributes off the event in here as necessary.
        @aggregate_id = event.aggregate_id
      end

      apply TodoAmended do |event|
      end

      apply TodoCompleted do |event|
        @completed = true
      end

      apply TodoAbandoned do |event|
        @abandoned = true
      end

      def add(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} already exists" if added?

        apply_event(TodoAdded,
          aggregate_id: id,
          body: payload,
        )
      end

      # The methods below are how this aggregate handles different commands.
      # Note how they raise new events to indicate the change in state.

      def amend(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} does not exist" unless added?
        raise UnprocessableEntity, "Todo #{id.inspect} is complete" if completed
        raise UnprocessableEntity, "Todo #{id.inspect} is abandoned" if abandoned

        apply_event(TodoAmended,
          aggregate_id: id,
          body: payload,
        )
      end

      def complete(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} does not exist" unless added?
        raise UnprocessableEntity, "Todo #{id.inspect} already complete" if completed
        raise UnprocessableEntity, "Todo #{id.inspect} already abandoned" if abandoned

        apply_event(TodoCompleted,
          aggregate_id: id,
          body: payload,
        )
      end

      def abandon(payload)
        raise UnprocessableEntity, "Todo #{id.inspect} does not exist" unless added?
        raise UnprocessableEntity, "Todo #{id.inspect} already complete" if completed
        raise UnprocessableEntity, "Todo #{id.inspect} already abandoned" if abandoned

        apply_event(TodoAbandoned,
          aggregate_id: id,
          body: payload,
        )
      end

      private

      def added?
        @aggregate_id
      end

      attr_reader :completed, :abandoned
    end
  end
end
