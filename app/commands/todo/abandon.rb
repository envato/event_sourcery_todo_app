require 'app/aggregates/todo'

module EventSourceryTodoApp
  module Commands
    module Todo
      module Abandon
        class Command
          attr_reader :payload, :aggregate_id

          def self.build(params)
            new(params).tap(&:validate)
          end

          def initialize(params)
            @payload = params.slice(:todo_id, :abandoned_on)
            @aggregate_id = payload.delete(:todo_id)
          end

          def validate
            raise BadRequest, 'todo_id is blank' if aggregate_id.nil?
            raise BadRequest, 'abandoned_on is blank' if payload[:abandoned_on].nil?
            begin
              Date.parse(payload[:abandoned_on]) if payload[:abandoned_on]
            rescue ArgumentError
              raise BadRequest, 'abandoned_on is invalid'
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
            aggregate.abandon(command.payload)
            repository.save(aggregate)
          end

          private

          attr_reader :repository
        end
      end
    end
  end
end
