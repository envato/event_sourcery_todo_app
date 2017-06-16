# Event Sourcery Todo Example App

[![Build Status](https://travis-ci.org/envato/event_sourcery_todo_app.svg?branch=master)](https://travis-ci.org/envato/event_sourcery_todo_app)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

An example event sourced/CQRS web application built using [EventSourcery](https://github.com/envato/event_sourcery) and its [Postgres event store implementation](https://github.com/envato/event_sourcery-postgres).

This application is intended to illustrate concepts in EventSourcery, how they relate to each other, and how to use them in practice.

## Get started

Ensure you have Postgres and Ruby 2.2 or higher installed.

Then run the setup script.

```sh
$ ./scripts/setup
```

Run the tests.

```sh
$ bundle exec rake
```

## Using the Application

Start the web app and event stream processors via Foreman.

```sh
$ foreman start
```

Then you can manage your Todos using the `request` CLI script.

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

### Events

These are our domain events. They are stored in our event store as a list of immutable facts over time. Together they form the source of truth for our application's state.

- `TodoAdded`
- `TodoCompleted`
- `TodoAbandoned`
- `TodoAmended`
- `StakeholderNotifiedOfTodoCompletion`

A `Todo` can have the following attributes:

- title
- description
- due_date
- stakeholder_email

### Commands

The set of command handlers and commands that can be issued against the system. These form an interface between the web API and the domain model in the aggregate.

### Aggregates

The domain is modeled via aggregates. In this application we only have one aggregate root: `Todo`. It loads its state from the event store (via the `repository`), executes commands, and raises new events which are saved back to the store (again via the `repository`).

### Projections

You can think of projections as read-only models. They are created and updated by projectors and in this case show different current state views over the events that are the source of truth for our application state.

- `OutstandingTodos`
- `CompletedTodos`
- `ScheduledTodos` (has due date)

### Reactors

Reactors listen for events and take some action. Often these actions will involve emitting other events into the store. Sometimes it may involve triggering side effects in external systems.

Reactors can be used to build [process managers or sagas](https://msdn.microsoft.com/en-us/library/jj591569.aspx).

- `TodoCompletedNotifier`
  - "sends" an email notifying stakeholders of todo completion.
  - Emits `StakeholderNotifiedOfTodoCompletion` event to record this fact.

## Routes

The application exposes a web UI with the following API.

```
GET /todos/outstanding
GET /todos/completed
GET /todos/scheduled
POST /todo/:id (add)
PUT /todo/:id (amend)
POST /todo/:id/complete
POST /todo/:id/abandon
```
