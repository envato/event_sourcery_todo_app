require 'app/aggregates/todo'

module EventSourceryTodoApp
  module Commands
    module Todo
      module Add
        class Command
          attr_reader :payload, :aggregate_id

          def initialize(params)
            @payload = params
            @aggregate_id = payload.delete(:todo_id)
          end

          def valid?
            raise BadRequest, 'title is blank' if payload[:title].nil?
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
            aggregate.add(command.payload.slice(:title, :description, :due_date, :stakeholder_email))
            repository.save(aggregate)
          end
        end
      end
    end
  end
end
