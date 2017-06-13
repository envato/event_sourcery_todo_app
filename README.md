# Event Sourcery Todo Example App

```
app
├── aggregates
│   └── todo.rb
├── commands
│   └── todo
│       └── add.rb
├── events
│   └── todo_added.rb
├── projections
│   └── current
│       ├── projector.rb
│       └── query.rb
├── reactors
│   └── notifier.rb
└── web
    └── server.rb
```

## Events

- TodoAdded
- TodoCompleted
- TodoAbandoned
- TodoAmended

## Aggregates

- Todo
  - title
  - description
  - due_date
  - stakeholder_email

## Projections

- Current
- Completed
- Scheduled (has due date)

## Reactor

- Notifier
  - "sends" email
  - Emits StakeholderNotified event
