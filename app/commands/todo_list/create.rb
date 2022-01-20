require 'app/aggregates/todo_list'

module EventSourceryTodoApp
    module Commands
        module TodoList
            module Create
                class Command
                    attr_reader :payload, :aggregate_id

                    def self.build(**args)
                        new(**args).tap(&:validate)
                    end

                    def initialize(params)
                        @payload = params.slice(
                            :todo_list_id,
                            :title
                        )

                        @aggregate_id = payload.delete(:todo_list_id)
                    end

                    def validate
                    end
                end
            
                class CommandHandler
                    def initialize(repository: EventSourceryTodoApp.repository)
                        @repository = repository
                    end
                    
                    def handle(command)
                        aggregate = repository.load(Aggregates::TodoList, command.aggregate_id)
                        aggregate.create(command.payload)
                        repository.save(aggregate)
                    end

                    private

                    attr_reader :repository
                end
            end
        end
    end
end


