class TodoAdded < Eventory::Event
  attribute :stream_id
  attribute :body
end
