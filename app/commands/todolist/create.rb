require 'app/aggregate/todolist'

module EventSourceryTodoApp
    module Commands
        module ToDoList
            module Create
                class Command
                    attr_reader :payload, :aggregate_id

                    def self.build(**args)
                        new(**args).tap(&:validate)
                    end

                    def initialize(params)
                        @payload = params.slice(
                            :todolist_id
                            :title,
                        )

                        @aggregate_id = payload.delete(:todolist_id)
                    end

                    def validate
                    end
                end
            
                class CommandHandler
                    def initialize(repository: EventSourceryTodoApp.repository)
                        @repository = repository
                    end
                    
                    def handle(command)
                        aggregate = repository.load(Aggregates::ToDoList, command.aggregrate_id)
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


