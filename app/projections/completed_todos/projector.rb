module EventSourceryTodoApp
  module Projections
    module CompletedTodos
      class Projector
        include EventSourcery::Postgres::Projector

        projector_name :completed_todos

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

        project TodoAdded do |event|
          table(:query_completed_todos_incomplete_todos).insert(
            todo_id: event.aggregate_id,
            title: event.body['title'],
            description: event.body['description'],
            due_date: event.body['due_date'],
            stakeholder_email: event.body['stakeholder_email'],
          )
        end

        project TodoAmended do |event|
          table(:query_completed_todos_incomplete_todos).where(
            todo_id: event.aggregate_id,
          ).update(
            event.body.slice('title', 'description', 'due_date', 'stakeholder_email')
          )
        end

        project TodoAbandoned do |event|
          table(:query_completed_todos_incomplete_todos).where(todo_id: event.aggregate_id).delete
        end

        project TodoCompleted do |event|
          todo = table(:query_completed_todos_incomplete_todos).where(todo_id: event.aggregate_id).first

          table(:query_completed_todos).insert(
            todo_id: event.aggregate_id,
            title: todo[:title],
            description: todo[:description],
            due_date: todo[:due_date],
            stakeholder_email: todo[:stakeholder_email],
            completed_on: event.body['completed_on'],
          )

          table(:query_completed_todos_incomplete_todos).where(todo_id: event.aggregate_id).delete
        end
      end
    end
  end
end
