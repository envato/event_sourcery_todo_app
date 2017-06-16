module EventSourceryTodoApp
  module Projections
    module Outstanding
      # Query handler that queries the projection table.
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[:query_outstanding_todos].all
        end
      end
    end
  end
end
