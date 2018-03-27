module EventSourceryTodoApp
  module Projections
    module OutstandingTodos
      class Projector < Eventory::Projector
        # include EventSourcery::Postgres::Projector

        def namespace
          :outstanding_todos
        end

        # Database tables that form the projection.

        table :query_outstanding_todos do
          column :todo_id, 'UUID NOT NULL'
          column :title, :text
          column :description, :text
          column :due_date, DateTime
          column :stakeholder_email, :text
        end

        # Event handlers that update the projection in response to different events
        # from the store.

        on TodoAdded do |event|
          table(:query_outstanding_todos).insert(
            todo_id: event.stream_id,
            title: event.data.body[:title],
            description: event.data.body[:description],
            due_date: event.data.body[:due_date],
            stakeholder_email: event.data.body[:stakeholder_email],
          )
        end

        on TodoAmended do |event|
          table(:query_outstanding_todos).where(
            todo_id: event.stream_id,
          ).update(
            event.data.body.slice(:title, :description, :due_date, :stakeholder_email)
          )
        end

        on TodoCompleted, TodoAbandoned do |event|
          table(:query_outstanding_todos).where(todo_id: event.stream_id).delete
        end
      end
    end
  end
end
