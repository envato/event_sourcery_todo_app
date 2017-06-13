module EventSourceryTodoApp
  module Projections
    module Outstanding
      class Query
        def self.handle
          EventSourceryTodoApp.projections_database[:outstanding].all
        end
      end
    end
  end
end
