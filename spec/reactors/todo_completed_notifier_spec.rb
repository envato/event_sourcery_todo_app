require 'app/reactors/todo_completed_notifier'

RSpec.describe EventSourceryTodoApp::Reactors::TodoCompletedNotifier do
  subject(:reactor) do
    described_class.new(
      event_source: EventSourceryTodoApp.event_source,
      event_sink: EventSourceryTodoApp.event_sink,
      db_connection: EventSourceryTodoApp.projections_database,
    )
  end

  describe '#process' do
    subject(:process) { stream.each { |event| reactor.process(event) } }

    let(:todo_id) { SecureRandom.uuid }
    let(:stream) { [] }

    before do
      reactor.setup
      allow(EventSourceryTodoApp::Services::SendEmail).to receive(:perform)
      allow(Date).to receive(:today).and_return(Date.parse('2017-06-13'))
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
        expect(EventSourceryTodoApp::Services::SendEmail).to have_received(:perform).with(
          email: 'the-governator@example.com',
          message: 'Your todo item You are terminated! has been completed!',
        )
      end

      it 'emits a StakeholderNotifiedOfTodoCompletion event' do
        emitted_event = EventSourceryTodoApp.event_source.get_next_from(1).first

        expect(emitted_event).to be_a(StakeholderNotifiedOfTodoCompletion)
        expect(emitted_event.body.to_h).to include('notified_on' => '2017-06-13')
      end

      it 'deletes the row from the reactor table' do
        row = EventSourceryTodoApp.projections_database[:reactor_todo_completed_notifier].first
        expect(row).to be_nil
      end
    end
  end
end
