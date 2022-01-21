module EventSourceryTodoApp
  module Projections
    module TodoLists
      class Projector
        include EventSourcery::Postgres::Projector

        projector_name :todo_lists

        table :query_todo_lists do
          column :todo_id, 'UUID NOT NULL'
          column :todo_list_id, 'UUID NOT NULL'
          column :todo_list_title, :text
          column :todo_title, :text
          column :state,  :text
        end

        table :query_todo_list_title do
          column :todo_list_id, 'UUID NOT NULL'
          column :title, :text
        end

        project TodoListCreated do |event|
          table(:query_todo_list_title).insert(
            todo_list_id: event.aggregate_id,
            title: event.body['title'],
          )
        end

        project TodoAdded do |event|
          table(:query_todo_lists).insert(
            todo_id: event.aggregate_id,
            todo_list_id: event.body['todo_list_id'],
            todo_list_title: table(:query_todo_list_title).where(todo_list_id: event.body['todo_list_id']).first[:title],
            todo_title: event.body['title'],
            state: "incomplete",
          )
        end
      end
    end
  end
end    

