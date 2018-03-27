module EventSourceryTodoApp
  module Projections
    module CompletedTodos
      class Projector < Eventory::Projector
        # projector_name :completed_todos
        def namespace
          :completed_todos
        end

        # Database tables that form the projection.

        table :query_completed_todos do
          column :todo_id, 'UUID NOT NULL'
          column :title, :text
          column :description, :text
          column :due_date, DateTime
          column :stakeholder_email, :text
          column :completed_on, DateTime
        end

        table :query_completed_todos_incomplete_todos do
          column :todo_id, 'UUID NOT NULL'
          column :title, :text
          column :description, :text
          column :due_date, DateTime
          column :stakeholder_email, :text
        end

        # Event handlers that update the projection in response to different events
        # from the store.

        on TodoAdded do |event|
          table(:query_completed_todos_incomplete_todos).insert(
            todo_id: event.stream_id,
            title: event.data.body[:title],
            description: event.data.body[:description],
            due_date: event.data.body[:due_date],
            stakeholder_email: event.data.body[:stakeholder_email],
          )
        end

        on TodoAmended do |event|
          table(:query_completed_todos_incomplete_todos).where(
            todo_id: event.stream_id,
          ).update(
            event.data.body.slice(:title, :description, :due_date, :stakeholder_email)
          )
        end

        on TodoAbandoned do |event|
          table(:query_completed_todos_incomplete_todos).where(todo_id: event.stream_id).delete
        end

        on TodoCompleted do |event|
          todo = table(:query_completed_todos_incomplete_todos).where(todo_id: event.stream_id).first

          table(:query_completed_todos).insert(
            todo_id: event.stream_id,
            title: todo[:title],
            description: todo[:description],
            due_date: todo[:due_date],
            stakeholder_email: todo[:stakeholder_email],
            completed_on: event.data.body[:completed_on],
          )

          table(:query_completed_todos_incomplete_todos).where(todo_id: event.stream_id).delete
        end
      end
    end
  end
end
