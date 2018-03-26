module EventSourceryTodoApp
  module Reactors
    class TodoCompletedNotifier < Eventory::Reactor
      # include EventSourcery::Postgres::Reactor

      SendEmail = ->(params) do
        puts <<~EMAIL
          -- Email Sent
          To: #{params[:email]}
          Message: #{params[:message]}
        EMAIL
      end

      # processor_name :todo_completed_notifier
      # emits_events StakeholderNotifiedOfTodoCompletion

      # Reactors often need to persist state so they can track what work they need
      # to do. Here we use a database table.
      table :reactor_todo_completed_notifier do
        column :todo_id, 'UUID NOT NULL'
        column :title, :text
        column :stakeholder_email, :text

        index :todo_id, unique: true
      end

      # Event handlers where we do our work. This can include updating internal,
      # emitting events, and/or calling external systems.

      on TodoAdded do |event|
        table.insert(
          todo_id: event.aggregate_id,
          title: event.body['title'],
          stakeholder_email: event.body['stakeholder_email'],
        )
      end

      on TodoAmended do |event|
        table.where(todo_id: event.aggregate_id).update(
          event.body.slice('title', 'stakeholder_email'),
        )
      end

      on TodoAbandoned do |event|
        table.where(todo_id: event.aggregate_id).delete
      end

      on TodoCompleted do |event|
        todo = table.where(todo_id: event.aggregate_id).first

        # Here we send an email to the stakeholder and record that fact using
        # an event in the store.
        unless todo[:stakeholder_email].to_s == ''
          SendEmail.call(
            email: todo[:stakeholder_email],
            message: "Your todo item #{todo[:title]} has been completed!",
          )

          emit_event(
            StakeholderNotifiedOfTodoCompletion.new(
              aggregate_id: event.aggregate_id,
              body: { notified_on: DateTime.now.new_offset(0) }
            )
          )
        end

        table.where(todo_id: event.aggregate_id).delete
      end
    end
  end
end
