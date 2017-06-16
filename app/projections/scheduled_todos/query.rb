module EventSourceryTodoApp
  module Projections
    module Scheduled
      # Query handler that queries the projection table.
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[:query_scheduled_todos].exclude(due_date: nil).all
        end
      end
    end
  end
end
