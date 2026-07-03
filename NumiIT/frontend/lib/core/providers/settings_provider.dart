import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class AppSettings {
  const AppSettings({
    this.locale = const Locale('en'),
    this.themeMode = AppThemeMode.system,
    this.onboardingDone = false,
    this.cameraInstructionsSeen = false,
    this.gridOverlay = false,
    this.flashDefault = 'off',
    this.confidenceThreshold = 0.6,
    this.modelName = 'NumiIT-Stub',
    this.modelVersion = '1.0.0-stub',
  });

  final Locale locale;
  final AppThemeMode themeMode;
  final bool onboardingDone;
  final bool cameraInstructionsSeen;
  final bool gridOverlay;
  final String flashDefault;
  final double confidenceThreshold;
  final String modelName;
  final String modelVersion;

  AppSettings copyWith({
    Locale? locale,
    AppThemeMode? themeMode,
    bool? onboardingDone,
    bool? cameraInstructionsSeen,
    bool? gridOverlay,
    String? flashDefault,
    double? confidenceThreshold,
    String? modelName,
    String? modelVersion,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      cameraInstructionsSeen:
          cameraInstructionsSeen ?? this.cameraInstructionsSeen,
      gridOverlay: gridOverlay ?? this.gridOverlay,
      flashDefault: flashDefault ?? this.flashDefault,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      modelName: modelName ?? this.modelName,
      modelVersion: modelVersion ?? this.modelVersion,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _keyLocale = 'locale';
  static const _keyTheme = 'theme';
  static const _keyOnboarding = 'onboarding_done';
  static const _keyCameraInstr = 'camera_instructions';
  static const _keyGrid = 'grid_overlay';
  static const _keyFlash = 'flash_default';
  static const _keyConf = 'confidence_threshold';

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_keyLocale) ?? 'en';
    final themeIdx = prefs.getInt(_keyTheme) ?? 2;
    state = AppSettings(
      locale: Locale(localeCode),
      themeMode: AppThemeMode.values[themeIdx.clamp(0, 2)],
      onboardingDone: prefs.getBool(_keyOnboarding) ?? false,
      cameraInstructionsSeen: prefs.getBool(_keyCameraInstr) ?? false,
      gridOverlay: prefs.getBool(_keyGrid) ?? false,
      flashDefault: prefs.getString(_keyFlash) ?? 'off',
      confidenceThreshold: prefs.getDouble(_keyConf) ?? 0.6,
      modelName: state.modelName,
      modelVersion: state.modelVersion,
    );
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> setCameraInstructionsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCameraInstr, true);
    state = state.copyWith(cameraInstructionsSeen: true);
  }

  Future<void> setGridOverlay(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGrid, value);
    state = state.copyWith(gridOverlay: value);
  }

  Future<void> setConfidenceThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyConf, value);
    state = state.copyWith(confidenceThreshold: value);
  }

  void setModelInfo(String name, String version) {
    state = state.copyWith(modelName: name, modelVersion: version);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
