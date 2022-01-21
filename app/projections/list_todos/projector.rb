module EventSourceryTodoApp
  module Projections
    module ListTodos
      class Projector
        include EventSourcery::Postgres::Projector

        projector_name :list_todos

        table :query_list_todos do
          column :todo_id, 'UUID NOT NULL'
          column :todo_list_id, 'UUID NOT NULL'
          column :todo_list_title, :text
          column :todo_title, :text
          column :state,  :text
        end

        table :query_todo_list do
          column :todo_list_id, 'UUID NOT NULL'
          column :title, :text
        end

        project TodoListCreated do
          table(:query_todo_list).insert(
            todo_list_id: event.aggregate_id,
            title: event.body['title'],
          )
        end

        project TodoAdded do |event|
          table(:query_list_todos).insert(
            todo_id: event.aggregate_id,
            todo_list_id: event.body['todo_list_id'],
            todo_title: event.body['title'],
            state: "incomplete",
          )
        end
      end
    end
  end
end    

