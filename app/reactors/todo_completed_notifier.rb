module EventSourceryTodoApp
  module Reactors
    class TodoCompletedNotifier
      include EventSourcery::Postgres::Reactor

      SendEmail = -> { }

      processor_name :todo_completed_notifier
      emits_events :stakeholder_notified_of_todo_completion

      table :reactor_todo_completed_notifier do
        column :todo_id, 'UUID NOT NULL'
        column :title, :text
        column :stakeholder_email, :text

        index :todo_id, unique: true
      end

      process TodoAdded do |event|
        table.insert(
          todo_id: event.aggregate_id,
          title: event.body['title'],
          stakeholder_email: event.body['stakeholder_email'],
        )
      end

      process TodoAmended do |event|
        table.where(todo_id: event.aggregate_id).update(
          slice(event.body, 'title', 'stakeholder_email'),
        )
      end

      process TodoAbandoned do |event|
        table.where(todo_id: event.aggregate_id).delete
      end

      process TodoCompleted do |event|
        todo = table.where(todo_id: event.aggregate_id).first

        unless todo[:stakeholder_email].to_s == ''
          SendEmail.call(
            email: todo[:stakeholder_email],
            message: "Your todo item #{todo[:title]} has been completed!",
          )

          emit_event(
            StakeholderNotifiedOfTodoCompletion.new(
              aggregate_id: event.aggregate_id,
              body: { notified_on: Date.today }
            )
          )
        end

        table.where(todo_id: event.aggregate_id).delete
      end

      private

      def slice(hash, *keys)
        hash.select { |k, v| keys.include?(k) }
      end
    end
  end
end
