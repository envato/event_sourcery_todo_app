require 'app/aggregates/todo'

module EventSourceryTodoApp
  module Commands
    module Todo
      module Complete
        class Command
          attr_reader :payload, :aggregate_id

          def self.build(**args)
            new(**args).tap(&:validate)
          end

          def initialize(params)
            @payload = params.slice(:todo_id, :completed_on)
            @aggregate_id = payload.delete(:todo_id)
          end

          def validate
            raise BadRequest, 'todo_id is blank' if aggregate_id.nil?
            raise BadRequest, 'completed_on is blank' if payload[:completed_on].nil?
            begin
              Date.parse(payload[:completed_on]) if payload[:completed_on]
            rescue ArgumentError
              raise BadRequest, 'completed_on is invalid'
            end
          end
        end

        class CommandHandler
          def initialize(repository: EventSourceryTodoApp.repository)
            @repository = repository
          end

          def handle(command)
            aggregate = repository.load(Aggregates::Todo, command.aggregate_id)
            aggregate.complete(command.payload)
            repository.save(aggregate)
          end

          private

          attr_reader :repository
        end
      end
    end
  end
end
