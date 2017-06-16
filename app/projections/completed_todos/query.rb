module EventSourceryTodoApp
  module Projections
    module CompletedTodos
      # Query handler that queries the projection table.
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[:query_completed_todos].all
        end
      end
    end
  end
end
