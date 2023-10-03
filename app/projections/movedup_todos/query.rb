module EventSourceryTodoApp
  module Projections
    module MovedupTodos
      # Query handler that queries the projection table.
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[:query_movedup_todos].all
        end
      end
    end
  end
end
