module EventSourceryTodoApp
  module Projections
    module Outstanding
      # Query handler that queries the projection table.
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[table].all
        end

        def self.table
          :outstanding_todos_query_outstanding_todos
        end
      end
    end
  end
end
