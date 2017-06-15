# Event Sourcery Todo Example App

[![Build Status](https://travis-ci.org/envato/event_sourcery_todo_app.svg?branch=master)](https://travis-ci.org/envato/event_sourcery_todo_app)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Get started

Ensure you have Postgres and Ruby 2.2 or higher installed.

Then run the setup script.

```sh
$ ./scripts/setup
```

## Using the Application

Start the web app and processors.

```sh
$ foreman start
```

Then you can manage your Todos using `request` CLI script.

```sh
# Add a todo
$ ./scripts/request add -i aac35923-39b4-4c39-ad5d-f79d67bb2fb2 -t "Get to the chopper" -d "It's in the trees" -s dillon@cia.gov -D 2017-01-01

# Amend
$ ./scripts/request amend -i aac35923-39b4-4c39-ad5d-f79d67bb2fb2 -t "Get to the chopper, NOW!"

# Complete
$ ./scripts/request complete -i aac35923-39b4-4c39-ad5d-f79d67bb2fb2 -D 2017-01-01

# Abandon
$ ./scripts/request abandon -i aac35923-39b4-4c39-ad5d-f79d67bb2fb2 -D 2017-01-01

# List
$ ./scripts/request list -l outstanding
$ ./scripts/request list -l scheduled
$ ./scripts/request list -l completed
```

## Application Structure

```
├── app
│   ├── aggregates
│   │   └── todo.rb
│   ├── commands
│   │   └── todo
│   │       ├── abandon.rb
│   │       ├── add.rb
│   │       ├── amend.rb
│   │       └── complete.rb
│   ├── errors.rb
│   ├── events
│   │   ├── stakeholder_notified_of_todo_completion.rb
│   │   ├── todo_abandoned.rb
│   │   ├── todo_added.rb
│   │   ├── todo_amended.rb
│   │   └── todo_completed.rb
│   ├── projections
│   │   ├── completed_todos
│   │   │   ├── projector.rb
│   │   │   └── query.rb
│   │   ├── outstanding_todos
│   │   │   ├── projector.rb
│   │   │   └── query.rb
│   │   └── scheduled_todos
│   │       ├── projector.rb
│   │       └── query.rb
│   ├── reactors
│   │   └── todo_completed_notifier.rb
│   ├── utils.rb
│   └── web
│       └── server.rb
├── config
│   └── environment.rb
```

## Routes

```
GET /todos/outstanding
GET /todos/completed
GET /todos/scheduled
POST /todo/:id (add)
PUT /todo/:id (amend)
POST /todo/:id/complete
POST /todo/:id/abandon
```

## Events

- `TodoAdded`
- `TodoCompleted`
- `TodoAbandoned`
- `TodoAmended`
- `StakeholderNotifiedOfTodoCompletion`

## Aggregates

- `Todo`
  - title
  - description
  - due_date
  - stakeholder_email

## Projections

- `OutstandingTodos`
- `CompletedTodos`
- `ScheduledTodos` (has due date)

## Reactors

- `TodoCompletedNotifier`
  - "sends" email
  - Emits `StakeholderNotifiedOfTodoCompletion` event
