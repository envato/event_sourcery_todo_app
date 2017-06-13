RSpec.describe 'add todo', type: :request do
  describe 'POST /todo/:todo_id' do
    let(:todo_id) { SecureRandom.uuid }

    it 'returns success' do
      post "/todo/#{todo_id}", {
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
  end
end
