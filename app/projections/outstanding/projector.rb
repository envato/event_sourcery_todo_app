module EventSourceryTodoApp
  module Projections
    module Outstanding
      class Projector
        include EventSourcery::Postgres::Projector

        projector_name :outstanding

        table :outstanding do
          column :todo_id, 'UUID NOT NULL'
          column :title, :text
          column :description, :text
          column :due_date, DateTime
          column :stakeholder_email, :text
        end

        project TodoAdded do |event|
          table.insert(
            todo_id: event.aggregate_id,
            title: event.body['title'],
            description: event.body['description'],
            due_date: event.body['due_date'],
            stakeholder_email: event.body['stakeholder_email'],
          )
        end
      end
    end
  end
end
