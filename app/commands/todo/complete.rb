require 'app/aggregates/todo'

module EventSourceryTodoApp
  module Commands
    module Todo
      module Complete
        class Command
          attr_reader :payload, :aggregate_id

          def initialize(params)
            @payload = params
            @aggregate_id = payload.delete(:todo_id)
          end

          def valid?
            raise BadRequest, 'completed_on is blank' if payload[:completed_on].nil?
            begin
              Date.parse(payload[:completed_on]) if payload[:completed_on]
            rescue ArgumentError
              raise BadRequest, 'completed_on is invalid'
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
            aggregate.complete(command.payload.slice(:title, :description, :due_date, :stakeholder_email, :completed_on))
            repository.save(aggregate)
          end
        end
      end
    end
  end
end
