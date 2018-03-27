module EventSourceryTodoApp
  module Projections
    module CompletedTodos
      # Query handler that queries the projection table.
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[table].all
        end

        def self.table
          [
            :completed_todos, 
            :query_completed_todos
          ].join("_").to_sym
        end
      end
    end
  end
end
