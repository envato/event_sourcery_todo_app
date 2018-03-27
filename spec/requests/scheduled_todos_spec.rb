require 'app/projections/scheduled_todos/projector'

RSpec.describe 'scheduled todos', type: :request do
  describe 'GET /todos/scheduled' do
    let(:todo_id_1) { SecureRandom.uuid }
    let(:todo_id_2) { SecureRandom.uuid }
    let(:todo_id_3) { SecureRandom.uuid }
    let(:todo_id_4) { SecureRandom.uuid }
    let(:todo_id_5) { SecureRandom.uuid }
    let(:todo_id_6) { SecureRandom.uuid }
    let(:events) do
      [
        TodoAdded.new(stream_id: todo_id_1, body: {
          title: "I don't do requests",
        }),
        TodoAdded.new(stream_id: todo_id_2, body: {
          title: "If it's hard to remember, it will be difficult to forget",
        }),
        TodoCompleted.new(stream_id: todo_id_1, body: {
          completed_on: '2017-06-13',
        }),
        TodoAmended.new(stream_id: todo_id_2, body: {
          title: "If it's hard to remember, it...",
          description: "Hmm...",
          due_date: '2017-06-13',
        }),
        TodoAdded.new(stream_id: todo_id_3, body: {
          title: 'Milk is for babies',
        }),
        TodoAdded.new(stream_id: todo_id_4, body: {
          title: 'Your clothes, give them to me, now!',
          due_date: '2017-06-13',
        }),
        TodoAbandoned.new(stream_id: todo_id_4, body: {
          abandoned_on: '2017-06-01',
        }),
        TodoAdded.new(stream_id: todo_id_5, body: {
          title: 'Your clothes, give them to me, now!',
          due_date: '2017-06-18',
        }),
        TodoAmended.new(stream_id: todo_id_5, body: {
          title: 'Your clothes, give them to me, now!',
          due_date: nil,
        }),
        TodoAdded.new(stream_id: todo_id_6, body: {
          title: "Tell Obama he needs to do something about those skinny legs. I'm going to make him do some squats",
          due_date: '2017-06-22',
        }),
      ]
    end
    let(:checkpoints) { Eventory::Checkpoints.new(database: EventSourceryTodoApp.config.database) }
    let(:projector) { 
      EventSourceryTodoApp::Projections::ScheduledTodos::Projector.new(
        event_store: EventSourceryTodoApp.event_store,
        checkpoints: checkpoints,
        database: EventSourceryTodoApp.config.database
      )
    }

    let(:recorded_events) do
      events.each_with_index.map do |event, i|
        Eventory::RecordedEvent.new(
          number: i,
          id: i,
          stream_id: event.stream_id,
          stream_version: i,
          type: event.class,
          data: event,
          recorded_at: Time.now,
          correlation_id: SecureRandom.uuid,
          causation_id: SecureRandom.uuid,
          metadata: nil
        )
      end
    end

    it 'returns a list of scheduled Todos' do
      projector.up

      recorded_events.each do |event|
        projector.process(event)
      end

      get '/todos/scheduled'

      expect(last_response.status).to be 200
      expect(JSON.parse(last_response.body, symbolize_names: true)).to eq([
        {
          todo_id: todo_id_2,
          title: "If it's hard to remember, it...",
          description: "Hmm...",
          due_date: '2017-06-13 00:00:00 +1000',
          stakeholder_email: nil,
        },
        {
          todo_id: todo_id_6,
          title: "Tell Obama he needs to do something about those skinny legs. I'm going to make him do some squats",
          description: nil,
          due_date: '2017-06-22 00:00:00 +1000',
          stakeholder_email: nil,
        },
      ])
    end
  end
end
