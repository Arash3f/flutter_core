# Features — Clean Architecture + Riverpod

Every feature is a self-contained folder. Nothing outside `features/<name>/` has
to change when a feature is added or deleted.

```
features/<name>/
├── domain/          ← pure Dart. No Flutter, no JSON, no packages.
│   ├── entities/         business objects
│   ├── repositories/     abstract contracts
│   └── usecases/         one business operation each
├── data/            ← how the data actually arrives
│   ├── models/           entity + serialization
│   ├── datasources/      SharedPreferences, HTTP, sqflite, …
│   └── repositories/      implements the domain contract
└── presentation/    ← Flutter
    ├── providers/        Riverpod wiring + screen state
    ├── screens/
    └── widgets/
```

## The dependency rule

Dependencies only ever point inwards:

```
presentation ──▶ domain ◀── data
```

`domain` imports nothing from `data` or `presentation`. That is what makes the
business rules testable without a device, and what lets you replace
`SharedPreferences` with a REST API by editing one file.

## Worked example: `todo`

- `domain/entities/todo.dart` — the entity, `Equatable`, no JSON
- `domain/repositories/todo_repository.dart` — the contract
- `domain/usecases/add_todo.dart` — the "title must not be blank / too long"
  rule. It lives here, not in the widget, so every screen obeys it
- `data/models/todo_model.dart` — `extends Todo`, adds `fromJson`/`toJson`
- `data/datasources/todo_local_data_source.dart` — the only file that knows
  about `SharedPreferences`
- `data/repositories/todo_repository_impl.dart` — translates data-source
  exceptions into domain `Failure`s
- `presentation/providers/todo_providers.dart` — the wiring diagram
- `presentation/screens/todo_screen.dart` — renders `AsyncValue`

`features/settings` is the other end of the scale: a feature with only a
presentation layer, because it has no business rule of its own.

## Real-world example: `auth` and `profile`

- [`features/auth`](./auth/README.md) is a complete backend-driven feature:
  - REST and GraphQL data sources behind one contract
  - token storage
  - use cases with real rules (keep tokens when offline, password repeat must
    match)
  - an app-wide `AsyncNotifier` session that the router listens to
- `features/profile` is presentation-only on top of auth's use cases. A
  feature may depend on another feature's **domain** (entities and use cases),
  never on its data layer.

## Error handling

There is no `Either`/`Result` type. Instead:

1. Data sources throw raw exceptions (`CacheException`, `ServerException`).
2. Repositories catch them and throw a domain
   [`Failure`](../core/error/failure.dart), which implements `Exception`.
3. The notifier wraps every call in `AsyncValue.guard`, so failures land in
   `AsyncError` and the UI reads them off `state`.

`AsyncValue` is already a result type — adding a second one would mean
unwrapping twice on every call. `Failure` is `sealed`, so a `switch` over it is
checked exhaustively at compile time.

## Riverpod conventions

- No code generation. Providers are declared by hand, so there is no
  `build_runner` step between editing a provider and running the app. Migrating
  to `riverpod_generator` later is mechanical.
- `Notifier` for synchronous state, `AsyncNotifier` for anything that awaits.
  `StateProvider` and `StateNotifierProvider` are legacy in Riverpod 3 and are
  not used.
- Every provider exposes an **abstract** type (`Provider<TodoRepository>`, not
  `Provider<TodoRepositoryImpl>`), so implementations stay swappable.
- Derived values get their own `Provider` (see `remainingTodoCountProvider`)
  instead of being computed in `build`, so the widget only rebuilds when that
  value changes.

## Adding a feature

1. `mkdir -p lib/features/<name>/{domain,data,presentation}`
2. Write the entity and the repository contract first — before deciding where
   the data comes from.
3. Add use cases for the operations the UI needs.
4. Implement the data source and the repository.
5. Wire it in `presentation/providers/<name>_providers.dart`.
