# Aggregates

The domain is modeled via aggregates. In this application we only have one aggregate root: `Todo`. It loads its state from the event store (via the `repository`), executes commands, and raises new events which are saved back to the store (again via the `repository`).
