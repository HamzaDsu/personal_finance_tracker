class AppStrings {
  AppStrings._();

  // Titles
  static const String appName = 'Personal Finance Tracker';
  static const String addTransaction = 'Add Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String deleteTransaction = 'Transaction deleted';
  static const String transactions = 'Transaction';

  // Theme
  static const String switchLight = 'Switch to Light';
  static const String switchDark = 'Switch to Dark';

  // DataSource
  static const String transactionsDataSource = 'transaction';
  static const String failedReadTransactions = 'Failed to read transactions';
  static const String failedSaveTransaction = 'Failed to save transaction';
  static const String failedDeleteTransaction = 'Failed to delete transaction';


  // Form Fields & Hints
  static const String amount = 'Amount';
  static const String amountHint = 'e.g. 49.99';
  static const String category = 'Category';
  static const String type = 'Type';
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String date = 'Date';
  static const String notes = 'Notes (optional)';
  static const String pick = 'Pick';
  static const String balance = 'Balance';
  static const String customRange = 'Custom Range';
  static const String daysRange = 'Last 30 Days';
  static const String monthRange = 'This Month';


  // Validation
  static const String amountRequired = 'Amount is required';
  static const String amountGreaterThanZero = 'Amount must be greater than 0';
  static const String invalidAmount = 'Invalid amount';
  static const String clearFilter = 'Clear date filter';
  static const String spendingCategory = 'Spending by Category';
  static const String somethingWrong = 'Something went wrong';


  // Buttons & Actions
  static const String confirm = 'Confirm';
  static const String saving = 'Saving...';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Dialogs & Snack bars
  static const String deleteTitle = 'Delete transaction?';
  static const String deleteContent = 'This action cannot be undone.';
  static const String savedTransaction = 'Transaction saved ✅';
  static const String updatedTransaction = 'Transaction updated ✅';
  static const String errorSaving = 'Failed to save transaction';

  // Empty State
  static const String noTransactions = 'No transactions yet';
  static const String emptyStateSub = 'Tap + to add your first income or expense.';
  static const String noExpense = 'No expense data to display';
}