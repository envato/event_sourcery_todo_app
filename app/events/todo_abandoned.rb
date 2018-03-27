class TodoAbandoned < Eventory::Event
  attribute :stream_id
  attribute :body
end
