require 'app/aggregates/todo'

module EventSourceryTodoApp
  module Commands
    module Todo
      module Abandon
        class Command
          attr_reader :payload, :aggregate_id

          def initialize(params)
            @payload = params
            @aggregate_id = payload.delete(:todo_id)
          end

          def valid?
            raise BadRequest, 'abandoned_on is blank' if payload[:abandoned_on].nil?
            begin
              Date.parse(payload[:abandoned_on]) if payload[:abandoned_on]
            rescue ArgumentError
              raise BadRequest, 'abandoned_on is invalid'
            end
          end
        end

        class CommandHandler
          def self.handle(command)
            repository = EventSourcery::Repository.new(
              event_source: EventSourceryTodoApp.event_source,
              event_sink: EventSourceryTodoApp.event_sink,
            )

            aggregate = repository.load(Aggregates::Todo, command.aggregate_id)
            aggregate.abandon(command.payload.slice(:title, :description, :due_date, :stakeholder_email, :abandoned_on))
            repository.save(aggregate)
          end
        end
      end
    end
  end
end
