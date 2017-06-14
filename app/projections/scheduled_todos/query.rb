module EventSourceryTodoApp
  module Projections
    module Scheduled
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[:query_scheduled_todos].exclude(due_date: nil).all
        end
      end
    end
  end
end
