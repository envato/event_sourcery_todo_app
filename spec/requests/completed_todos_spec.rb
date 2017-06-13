require 'app/projections/completed_todos/projector'

RSpec.describe 'completed todos', type: :request do
  describe 'GET /todos/completed' do
    let(:todo_id_1) { SecureRandom.uuid }
    let(:todo_id_2) { SecureRandom.uuid }
    let(:todo_id_3) { SecureRandom.uuid }
    let(:todo_id_4) { SecureRandom.uuid }
    let(:events) do
      [
        TodoAdded.new(aggregate_id: todo_id_1, body: {
          title: "I don't do requests",
        }),
        TodoAdded.new(aggregate_id: todo_id_2, body: {
          title: "If it's hard to remember, it will be difficult to forget",
          due_date: '2017-06-13',
        }),
        TodoCompleted.new(aggregate_id: todo_id_1, body: {
          completed_on: '2017-06-13',
        }),
        TodoAmended.new(aggregate_id: todo_id_2, body: {
          title: "If it's hard to remember, it...",
          description: "Hmm...",
        }),
        TodoCompleted.new(aggregate_id: todo_id_2, body: {
          completed_on: '2017-06-15',
        }),
        TodoAdded.new(aggregate_id: todo_id_3, body: {
          title: 'Milk is for babies',
        }),
        TodoAdded.new(aggregate_id: todo_id_4, body: {
          title: 'Your clothes, give them to me, now!',
        }),
        TodoAbandoned.new(aggregate_id: todo_id_4, body: {
          abandoned_on: '2017-06-01',
        }),
      ]
    end
    let(:projector) { EventSourceryTodoApp::Projections::CompletedTodos::Projector.new }

    it 'returns a list of completed Todos' do
      projector.setup

      events.each do |event|
        projector.process(event)
      end

      get '/todos/completed'

      expect(last_response.status).to be 200
      expect(JSON.parse(last_response.body, symbolize_names: true)).to eq([
        {
          todo_id: todo_id_1,
          title: "I don't do requests",
          description: nil,
          due_date: nil,
          stakeholder_email: nil,
          completed_on: '2017-06-13 00:00:00 UTC',
        },
        {
          todo_id: todo_id_2,
          title: "If it's hard to remember, it...",
          description: "Hmm...",
          due_date: '2017-06-13 00:00:00 UTC',
          stakeholder_email: nil,
          completed_on: '2017-06-15 00:00:00 UTC',
        },
      ])
    end
  end
end
