module EventSourceryTodoApp
  module Projections
    module Scheduled
      # Query handler that queries the projection table.
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[table].exclude(due_date: nil).all
        end

        def self.table
          [
            :scheduled_todos,
            :query_scheduled_todos
          ].join("_").to_sym
        end
      end
    end
  end
end
