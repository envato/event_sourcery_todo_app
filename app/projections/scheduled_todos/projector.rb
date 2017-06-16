module EventSourceryTodoApp
  module Projections
    module ScheduledTodos
      class Projector
        include EventSourcery::Postgres::Projector

        projector_name :scheduled_todos

        # Database tables that form the projections

        table :query_scheduled_todos do
          column :todo_id, 'UUID NOT NULL'
          column :title, :text
          column :description, :text
          column :due_date, DateTime
          column :stakeholder_email, :text

          index :todo_id, unique: true
          index :due_date
        end

        # Event handlers that update the projection in response to different events
        # from the store.

        project TodoAdded do |event|
          table.insert(
            todo_id: event.aggregate_id,
            title: event.body['title'],
            description: event.body['description'],
            due_date: event.body['due_date'],
            stakeholder_email: event.body['stakeholder_email'],
          )
        end

        project TodoAmended do |event|
          table.where(
            todo_id: event.aggregate_id,
          ).update(
            slice(event.body, 'title', 'description', 'due_date', 'stakeholder_email')
          )
        end

        project TodoCompleted, TodoAbandoned do |event|
          table.where(todo_id: event.aggregate_id).delete
        end

        private

        def slice(hash, *keys)
          hash.select { |k, v| keys.include?(k) }
        end
      end
    end
  end
end
