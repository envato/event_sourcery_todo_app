RSpec.describe 'amend todo', type: :request do
  describe 'PUT /todo/:todo_id' do
    let(:todo_id) { SecureRandom.uuid }

    context 'when updating an attribute' do
      before do
        EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id, body: {
          title: '2000 squats',
          description: 'Leg day.',
          due_date: '2017-07-13',
          stakeholder_email: 'the-governator@example.com',
        })
      end

      it 'returns success' do
        put_json "/todo/#{todo_id}", {
          description: 'It IS leg day!',
        }

        expect(last_response.status).to be 200
        expect(last_event(todo_id)).to be_a TodoAmended
        expect(last_event(todo_id).aggregate_id).to eq todo_id
        expect(last_event(todo_id).body).to eq(
          'description' => 'It IS leg day!',
        )
      end
    end

    context 'with an invalid date' do
      it 'returns bad request' do
        put_json "/todo/#{todo_id}", due_date: 'invalid'

        expect(last_response.status).to be 400
        expect(last_response.body).to eq 'Bad Request: due_date is invalid'
      end
    end

    context 'when the Todo does not exist' do
      it 'returns unprocessable entity' do
        put_json "/todo/#{todo_id}"

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" does not exist}
      end
    end

    context 'when the Todo is already complete' do
      before do
        EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id)
        EventSourceryTodoApp.event_sink.sink TodoCompleted.new(aggregate_id: todo_id)
      end

      it 'returns unprocessable entity' do
        put_json "/todo/#{todo_id}"

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" is complete}
      end
    end

    context 'when the Todo is already abandoned' do
      before do
        EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id)
        EventSourceryTodoApp.event_sink.sink TodoAbandoned.new(aggregate_id: todo_id)
      end

      it 'returns unprocessable entity' do
        put_json "/todo/#{todo_id}"

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" is abandoned}
      end
    end
  end
end
