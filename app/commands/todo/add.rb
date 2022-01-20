require 'app/aggregates/todo'

module EventSourceryTodoApp
  module Commands
    module Todo
      module Add
        class Command
          attr_reader :payload, :aggregate_id

          def self.build(**args)
            new(**args).tap(&:validate)
          end

          def initialize(params)
            @payload = params.slice(
              :todo_id,
              :todo_list_id,
              :title,
              :description,
              :due_date,
              :stakeholder_email
            )
            @aggregate_id = payload.delete(:todo_id)
          end

          def validate
            raise BadRequest, 'todo_id is blank' if aggregate_id.nil?
            raise BadRequest, 'title is blank' if payload[:title].nil?
            begin
              Date.parse(payload[:due_date]) if payload[:due_date]
            rescue ArgumentError
              raise BadRequest, 'due_date is invalid'
            end
          end
        end

        class CommandHandler
          def initialize(repository: EventSourceryTodoApp.repository)
            @repository = repository
          end

          # Handle loads the aggregate state from the store using the repository,
          # defers to the aggregate to execute the command, and saves off any newly
          # raised events to the store.
          def handle(command)
            aggregate = repository.load(Aggregates::Todo, command.aggregate_id)
            aggregate.add(command.payload)
            repository.save(aggregate)
          end

          private

          attr_reader :repository
        end
      end
    end
  end
end
