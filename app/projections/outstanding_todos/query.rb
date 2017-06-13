module EventSourceryTodoApp
  module Projections
    module Outstanding
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[:query_outstanding_todos].all
        end
      end
    end
  end
end
