import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/theme_storage.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeStorage _storage;

  ThemeCubit({ThemeStorage? storage})
      : _storage = storage ?? ThemeStorage(),
        super(const ThemeState.light()) {
    _init();
  }

  Future<void> _init() async {
    final mode = await _storage.loadThemeMode();
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> toggleTheme() async {
    final next = state.isDark ? ThemeMode.light : ThemeMode.dark;
    emit(state.copyWith(themeMode: next));
    await _storage.saveThemeMode(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _storage.saveThemeMode(mode);
  }
}
