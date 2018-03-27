RSpec.describe 'complete todo', type: :request do
  describe 'POST /todo/:todo_id/complete' do
    let(:todo_id) { SecureRandom.uuid }

    it 'returns success' do
      EventSourceryTodoApp.event_store.append todo_id, TodoAdded.new(stream_id: todo_id)

      post_json "/todo/#{todo_id}/complete", {
        completed_on: '2017-07-13',
      }

      expect(last_response.status).to be 200
      expect(last_event(todo_id)).to be_a TodoCompleted
      expect(last_event(todo_id).stream_id).to eq todo_id
      expect(last_event(todo_id).body).to eq(
        'completed_on' => '2017-07-13',
      )
    end

    context 'when the Todo does not exist' do
      it 'returns unprocessable entity' do
        post_json "/todo/#{todo_id}/complete", {
          completed_on: '2017-07-13',
        }

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" does not exist}
      end
    end

    context 'when the Todo is already complete' do
      before do
        EventSourceryTodoApp.event_store.append todo_id, TodoAdded.new(stream_id: todo_id)

        post_json "/todo/#{todo_id}/complete", {
          completed_on: '2017-07-13',
        }
      end

      it 'returns unprocessable entity' do
        post_json "/todo/#{todo_id}/complete", {
          completed_on: '2017-07-14',
        }

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" already complete}
      end
    end

    context 'when the Todo has been abandoned' do
      before do
        EventSourceryTodoApp.event_store.append todo_id, TodoAdded.new(stream_id: todo_id)
        EventSourceryTodoApp.event_store.append todo_id, TodoAbandoned.new(stream_id: todo_id)
      end

      it 'returns unprocessable entity' do
        post_json "/todo/#{todo_id}/complete", {
          completed_on: '2017-07-14',
        }

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" already abandoned}
      end
    end

    context 'with a missing date' do
      it 'returns bad request entity' do
        EventSourceryTodoApp.event_store.append todo_id, TodoAdded.new(stream_id: todo_id)

        post_json "/todo/#{todo_id}/complete"

        expect(last_response.status).to be 400
        expect(last_response.body).to eq 'Bad Request: completed_on is blank'
      end
    end

    context 'with an invalid date' do
      it 'returns bad request entity' do
        EventSourceryTodoApp.event_store.append todo_id, TodoAdded.new(stream_id: todo_id)

        post_json "/todo/#{todo_id}/complete", {
          completed_on: 'invalid',
        }

        expect(last_response.status).to be 400
        expect(last_response.body).to eq 'Bad Request: completed_on is invalid'
      end
    end
  end
end
