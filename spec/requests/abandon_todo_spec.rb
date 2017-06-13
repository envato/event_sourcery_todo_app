RSpec.describe 'abandon todo', type: :request do
  describe 'POST /todo/:todo_id/abandon' do
    let(:todo_id) { SecureRandom.uuid }

    it 'returns success' do
      EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id)

      post "/todo/#{todo_id}/abandon", {
        abandoned_on: '2017-07-13',
      }

      expect(last_response.status).to be 200
      expect(last_event(todo_id)).to be_a TodoAbandoned
      expect(last_event(todo_id).aggregate_id).to eq todo_id
      expect(last_event(todo_id).body).to eq(
        'abandoned_on' => '2017-07-13',
      )
    end

    context 'when the Todo does not exist' do
      it 'returns unprocessable entity' do
        post "/todo/#{todo_id}/abandon", {
          abandoned_on: '2017-07-13',
        }

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" does not exist}
      end
    end

    context 'when the Todo has already been completed' do
      before do
        EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id)
        EventSourceryTodoApp.event_sink.sink TodoCompleted.new(aggregate_id: todo_id)
      end

      it 'returns unprocessable entity' do
        post "/todo/#{todo_id}/abandon", {
          abandoned_on: '2017-07-14',
        }

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" already complete}
      end
    end

    context 'when the Todo has already been abandoned' do
      before do
        EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id)
        EventSourceryTodoApp.event_sink.sink TodoAbandoned.new(aggregate_id: todo_id)
      end

      it 'returns unprocessable entity' do
        post "/todo/#{todo_id}/abandon", {
          abandoned_on: '2017-07-14',
        }

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" already abandoned}
      end
    end

    context 'with a missing date' do
      it 'returns bad request entity' do
        EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id)

        post "/todo/#{todo_id}/abandon"

        expect(last_response.status).to be 400
        expect(last_response.body).to eq 'Bad Request: abandoned_on is blank'
      end
    end

    context 'with an invalid date' do
      it 'returns bad request entity' do
        EventSourceryTodoApp.event_sink.sink TodoAdded.new(aggregate_id: todo_id)

        post "/todo/#{todo_id}/abandon", {
          abandoned_on: 'invalid',
        }

        expect(last_response.status).to be 400
        expect(last_response.body).to eq 'Bad Request: abandoned_on is invalid'
      end
    end
  end
end
