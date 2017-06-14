RSpec.describe 'add todo', type: :request do
  describe 'POST /todo/:todo_id' do
    let(:todo_id) { SecureRandom.uuid }

    it 'returns success' do
      post_json "/todo/#{todo_id}", {
        title: '2000 squats',
        description: 'Leg day.',
        due_date: '2017-07-13',
        stakeholder_email: 'the-governator@example.com',
      }

      expect(last_response.status).to be 201
      expect(last_event(todo_id)).to be_a TodoAdded
      expect(last_event(todo_id).aggregate_id).to eq todo_id
      expect(last_event(todo_id).body).to eq(
        'title' => '2000 squats',
        'description' => 'Leg day.',
        'due_date' => '2017-07-13',
        'stakeholder_email' => 'the-governator@example.com',
      )
    end

    context 'when the Todo already exists' do
      before do
        post_json "/todo/#{todo_id}", title: 'Bicep curls for days'
      end

      it 'returns unprocessable entity' do
        post_json "/todo/#{todo_id}", title: 'Get to the chopper!'

        expect(last_response.status).to be 422
        expect(last_response.body).to eq %Q{Unprocessable Entity: Todo "#{todo_id}" already exists}
      end
    end

    context 'with a missing title' do
      it 'returns bad request' do
        post_json "/todo/#{todo_id}"

        expect(last_response.status).to be 400
        expect(last_response.body).to eq 'Bad Request: title is blank'
      end
    end

    context 'with an invalid date' do
      it 'returns bad request' do
        post_json "/todo/#{todo_id}", title: "It's not a tumor", due_date: 'invalid'

        expect(last_response.status).to be 400
        expect(last_response.body).to eq 'Bad Request: due_date is invalid'
      end
    end
  end
end
