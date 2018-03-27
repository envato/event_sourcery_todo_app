module EventSourceryTodoApp
  module Projections
    module ScheduledTodos
      class Projector < Eventory::Projector
        # include EventSourcery::Postgres::Projector

        # projector_name :scheduled_todos
        def namespace
          :scheduled_todos
        end

        # Database tables that form the projection.

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

        on TodoAdded do |event|
          table(:query_scheduled_todos).insert(
            todo_id: event.stream_id,
            title: event.data.body[:title],
            description: event.data.body[:description],
            due_date: event.data.body[:due_date],
            stakeholder_email: event.data.body[:stakeholder_email],
          )
        end

        on TodoAmended do |event|
          table(:query_scheduled_todos).where(
            todo_id: event.stream_id,
          ).update(
            slice(event.data.body, :title, :description, :due_date, :stakeholder_email)
          )
        end

        on TodoCompleted, TodoAbandoned do |event|
          table(:query_scheduled_todos).where(todo_id: event.stream_id).delete
        end

        private

        def slice(hash, *keys)
          hash.select { |k, v| keys.include?(k) }
        end
      end
    end
  end
end
