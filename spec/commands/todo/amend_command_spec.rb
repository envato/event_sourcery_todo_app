require 'app/commands/todo/amend'

RSpec.describe EventSourceryTodoApp::Commands::Todo::Amend::Command do
  describe '.build' do
    subject(:build) {
      described_class.build(params)
    }

    context 'without a todo_id' do
      let(:params) {
        {
          title: 'Stick around',
          due_date: '2017-06-16'
        }
      }
      it 'raises as error' do
        expect { build }.to raise_error(
          EventSourceryTodoApp::BadRequest,
          'todo_id is blank'
        )
      end
    end

    context 'with an invalid abandoned_on date' do
      let(:params) {
        {
          todo_id: SecureRandom.uuid,
          title: 'Stick around',
          due_date: 'not a date'
        }
      }
      it 'raises as error' do
        expect { build }.to raise_error(
          EventSourceryTodoApp::BadRequest,
          'due_date is invalid'
        )
      end
    end
  end
end
