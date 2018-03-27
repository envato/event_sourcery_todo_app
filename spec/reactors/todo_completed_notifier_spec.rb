require 'app/reactors/todo_completed_notifier'

RSpec.describe EventSourceryTodoApp::Reactors::TodoCompletedNotifier do
  let(:checkpoints) { Eventory::Checkpoints.new(database: EventSourceryTodoApp.config.database) }

  subject(:reactor) do
    described_class.new(
      event_store: EventSourceryTodoApp.event_store,
      checkpoints: checkpoints,
      database: EventSourceryTodoApp.config.database,
    )
  end

  describe '#process' do
    subject(:process) { stream.each { |event| reactor.process(event) } }

    let(:todo_id) { SecureRandom.uuid }
    let(:current_date) { DateTime.parse('2017-06-13 00:00:00 +10:00') }
    let(:stream) { [] }

    before do
      reactor.up
      allow(described_class::SendEmail).to receive(:call)
      allow(DateTime).to receive(:now).and_return(current_date)
      process
    end

    context 'when a todo is added' do
      let(:stream) do
        [
          TodoAdded.new(aggregate_id: todo_id, body: {
            title: 'You are terminated!',
            stakeholder_email: 'the-governator@example.com',
          }),
        ]
      end

      it 'adds a row to the reactor table' do
        row = EventSourceryTodoApp.projections_database[:reactor_todo_completed_notifier].first
        expect(row).to eq(
          todo_id: todo_id,
          title: 'You are terminated!',
          stakeholder_email: 'the-governator@example.com',
        )
      end
    end

    context 'when a todo is amended' do
      let(:stream) do
        [
          TodoAdded.new(aggregate_id: todo_id, body: {
            title: 'You are terminated!',
            stakeholder_email: 'the-governator@example.com',
          }),
          TodoAmended.new(aggregate_id: todo_id, body: {
            stakeholder_email: 'the-governator@example.gov',
          }),
        ]
      end

      it 'updates the row in the reactor table' do
        row = EventSourceryTodoApp.projections_database[:reactor_todo_completed_notifier].first
        expect(row).to eq(
          todo_id: todo_id,
          title: 'You are terminated!',
          stakeholder_email: 'the-governator@example.gov',
        )
      end
    end

    context 'when a todo is abandoned' do
      let(:stream) do
        [
          TodoAdded.new(aggregate_id: todo_id, body: {
            title: 'You are terminated!',
            stakeholder_email: 'the-governator@example.com',
          }),
          TodoAbandoned.new(aggregate_id: todo_id),
        ]
      end

      it 'deletes the row from the reactor table' do
        row = EventSourceryTodoApp.projections_database[:reactor_todo_completed_notifier].first
        expect(row).to be_nil
      end
    end

    context 'when a todo is completed' do
      context 'when the todo has a stakeholder' do
        let(:stream) {
          [
            TodoAdded.new(aggregate_id: todo_id, body: {
              title: 'You are terminated!',
              stakeholder_email: 'the-governator@example.com',
            }),
            TodoCompleted.new(aggregate_id: todo_id),
          ]
        }

        it 'sends an email' do
          expect(described_class::SendEmail).to have_received(:call).with(
            email: 'the-governator@example.com',
            message: 'Your todo item You are terminated! has been completed!',
          )
        end

        it 'emits a StakeholderNotifiedOfTodoCompletion event' do
          emitted_event = EventSourceryTodoApp.event_source.get_next_from(1).first

          expect(emitted_event).to be_a(StakeholderNotifiedOfTodoCompletion)
          expect(emitted_event.body.to_h).to include('notified_on' => '2017-06-12T14:00:00+00:00')
        end

        it 'deletes the row from the reactor table' do
          row = EventSourceryTodoApp.projections_database[:reactor_todo_completed_notifier].first
          expect(row).to be_nil
        end
      end

      context 'when the todo does not have a stakeholder' do
        let(:stream) {
          [
            TodoAdded.new(aggregate_id: todo_id, body: {
              title: 'You are terminated!',
            }),
            TodoCompleted.new(aggregate_id: todo_id),
          ]
        }

        it 'does not send an email' do
          expect(described_class::SendEmail).to_not have_received(:call)
        end

        it 'does not emit a StakeholderNotifiedOfTodoCompletion event' do
          emitted_event = EventSourceryTodoApp.event_source.get_next_from(1).first
          expect(emitted_event).to_not be_a(StakeholderNotifiedOfTodoCompletion)
        end

        it 'deletes the row from the reactor table' do
          row = EventSourceryTodoApp.projections_database[:reactor_todo_completed_notifier].first
          expect(row).to be_nil
        end
      end
    end
  end
end
