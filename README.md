# Personal Finance Tracker (Flutter)

A lightweight personal finance tracker that supports adding income/expense transactions, viewing balance, filtering, and persisting data locally.

## Features
- Add transactions (amount, type, category, date, notes)
- View current balance (income - expense)
- Filter transactions (All / Income / Expense)
- Local persistence (Hive) for transactions
- Theme toggle (Light/Dark) with persistence (SharedPreferences)

## Architecture
This project follows a feature-first structure with clear separation of concerns:

- **Presentation**: UI widgets + BLoC for state management (`flutter_bloc`)
- **Domain**: entities, repository contracts, and use cases
- **Data**: repository implementations and local data sources (Hive)

Data flow:
UI → Bloc → Use Case → Repository → Local Data Source (Hive)

## State Management
- `ThemeCubit` manages theme mode and persists preference using SharedPreferences.
- `TransactionBloc` manages:
    - loading transactions from local storage
    - adding transactions
    - filtering (All/Income/Expense)
    - computed values (income, expense, balance)

## Persistence
- **Transactions**: Hive box (`transactions`) keyed by transaction id.
- **Theme**: SharedPreferences key (`theme_mode`).

## Tradeoffs & Decisions
- Categories are kept as a simple predefined list for speed and clarity (can be made user-configurable).
- Hive chosen for local storage due to simplicity and fast setup for a take-home assignment.
- Minimal manual dependency wiring (no DI framework) to keep the sample easy to read.

## Improvements (if more time)
- Edit/Delete transactions (delete is quick, edit requires UI work)
- Date range filtering
- Category analytics / charts (e.g., spend per category)
- Export/import (CSV)
- Unit tests for repository and bloc + golden UI tests

## Getting Started
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
