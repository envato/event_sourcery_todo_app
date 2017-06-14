require 'app/aggregates/todo'

module EventSourceryTodoApp
  module Commands
    module Todo
      module Amend
        class Command
          attr_reader :payload, :aggregate_id

          def initialize(params)
            @payload = params.slice(
              :todo_id,
              :title,
              :description,
              :due_date,
              :stakeholder_email
            )
            @aggregate_id = payload.delete(:todo_id)
          end

          def valid?
            begin
              Date.parse(payload[:due_date]) if payload[:due_date]
            rescue ArgumentError
              raise BadRequest, 'due_date is invalid'
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
            aggregate.amend(command.payload)
            repository.save(aggregate)
          end
        end
      end
    end
  end
end
