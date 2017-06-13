require 'app/projections/outstanding/projector'

RSpec.describe 'outstanding todos', type: :request do
  describe 'GET /todos/outstanding' do
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
    let(:projector) { EventSourceryTodoApp::Projections::Outstanding::Projector.new }

    it 'returns a list of outstanding Todos' do
      projector.setup

      events.each do |event|
        projector.process(event)
      end

      get '/todos/outstanding'

      expect(last_response.status).to be 200
      expect(JSON.parse(last_response.body, symbolize_names: true)).to eq([
        {
          todo_id: todo_id_2,
          title: "If it's hard to remember, it...",
          description: "Hmm...",
          due_date: '2017-06-13 00:00:00 UTC',
          stakeholder_email: nil,
        },
        {
          todo_id: todo_id_3,
          title: 'Milk is for babies',
          description: nil,
          due_date: nil,
          stakeholder_email: nil,
        },
      ])
    end
  end
end
