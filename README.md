# Personal Finance Tracker (Flutter)

A lightweight, offline-first personal finance tracker built with Flutter.
The app allows users to track income and expenses, view balances, edit/delete transactions, filter data, visualize spending, and persist everything locally with a clean, testable architecture.

## Features
- Add income & expense transactions
- Edit/update existing transactions (tap a transaction to edit)
- Delete transactions (swipe-to-delete with confirmation)
- View current balance, total income & total expense
- Filter transactions (All / Income / Expense)
- Spending by Category chart (pie chart) with legend
- Local persistence using Hive
- Light/Dark theme toggle with persistence (SharedPreferences)
- Structured error handling using exceptions & failures
- Unit-tested business logic (TransactionBloc tests)

## Architecture
This project follows a feature-first, clean architecture–inspired structure with clear separation of responsibilities.

### Layers
- Presentation
  - UI widgets
  - Pages
  - BLoC / Cubit for state management (flutter_bloc)

- Domain
  - Entities
  - Repository contracts
  - Use cases (Load, Add, Update, Delete transactions)

- Data
  - Repository implementations
  - Local data source (Hive)
  - Data models

### Data Flow
UI → Bloc → Use Case → Repository → Local Data Source (Hive)

## State Management
### Theme
- ThemeCubit manages theme mode
- Persists theme preference using SharedPreferences
- Supports Light & Dark themes

### Transactions
- TransactionBloc manages:
  - Loading transactions
  - Adding new transactions
  - Updating existing transactions
  - Deleting transactions
  - Filtering (All / Income / Expense)
  - Derived values:
    - Total income
    - Total expense
    - Balance

## Persistence
- Transactions
  - Stored in Hive box: transactions
  - Keyed by transaction id
  - Uses upsert for add/update operations

- Theme
  - Stored using SharedPreferences
  - Key: theme_mode

## Error Handling
The app uses a structured error architecture:

### Data Layer
- Throws typed exceptions:
  - StorageException

### Domain / Repository Layer
- Converts exceptions into failures:
  - StorageFailure
  - UnknownFailure

### Presentation Layer
- Bloc emits failure states with user-friendly messages
- UI reacts using SnackBars

This prevents raw exceptions from leaking into the UI and keeps error handling consistent and testable.

## Charts
- Spending by Category is computed from expense transactions only.
- Categories are aggregated in a small utility function and visualized with a pie chart.
- The pie chart uses a simple color palette derived from category names to keep colors consistent.

## Testing
### Unit Tests Implemented
- TransactionBloc unit tests using:
  - bloc_test
  - mocktail

### Covered Scenarios
- Load transactions (success & failure)
- Add transaction
- Update transaction
- Delete transaction
- Change filter
- Balance calculation logic

Tests are fast, deterministic, and do not depend on Hive.

## Tradeoffs & Decisions
- Categories are predefined for simplicity and clarity (can be made user-configurable)
- Hive chosen for offline-first local persistence with minimal boilerplate
- Manual dependency wiring used instead of a DI framework to keep the code easy to read
- Bloc chosen to demonstrate scalable state management and enable robust testing
- Chart logic is derived from existing Bloc state (no extra state management needed)

## Improvements (If More Time)
- Date range filtering
- Category analytics (top categories, trends) and additional chart types (bar/line)
- CSV export/import
- Undo delete functionality
- Cloud sync and authentication

## Getting Started
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run

## Notes
- The project was developed incrementally, step by step
- Each feature was implemented end-to-end (UI → Bloc → Domain → Data)
- Focus was placed on clean architecture, testability, and maintainability
