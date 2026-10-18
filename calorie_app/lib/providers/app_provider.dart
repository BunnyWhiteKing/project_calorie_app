import 'package:flutter/foundation.dart';
import '../models/app_models.dart';

class AppProvider with ChangeNotifier {
  // Map จัดเก็บข้อมูลของแต่ละบัญชี (Key: username, Value: UserAccount)
  final Map<String, UserAccount> _accounts = {};
  String? _currentUsername;

  // Getters
  List<UserAccount> get savedAccounts => _accounts.values.toList();
  UserAccount? get currentAccount => _currentUsername != null ? _accounts[_currentUsername] : null;

  bool get isLoggedIn => _currentUsername != null;
  bool get hasCompletedOnboarding => currentAccount?.hasCompletedOnboarding ?? false;
  UserProfile? get userProfile => currentAccount?.profile;
  List<IngredientItem> get currentMealIngredients => currentAccount?.currentMealIngredients ?? [];
  Map<String, double> get dailyCalorieLogs => currentAccount?.dailyCalorieLogs ?? {};

  double get currentMealTotalCalories {
    final items = currentMealIngredients;
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.totalCalories);
  }

  String getDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  double? getCaloriesForDate(DateTime date) {
    return dailyCalorieLogs[getDateKey(date)];
  }

  void saveDailyCalories(DateTime date, double calories) {
    if (currentAccount != null) {
      currentAccount!.dailyCalorieLogs[getDateKey(date)] = calories;
      notifyListeners();
    }
  }

  // สลับเข้าสู่ระบบ หรือ สร้างบัญชีใหม่
  void login(String username) {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;

    if (!_accounts.containsKey(trimmed)) {
      _accounts[trimmed] = UserAccount(
        username: trimmed,
        profile: UserProfile(
          name: trimmed,
          height: 170,
          weight: 60,
          age: 20,
          gender: 'male',
          program: WeightLossProgram.generalWarmup,
        ),
      );
    }
    _currentUsername = trimmed;
    notifyListeners();
  }

  // ออกจากระบบ
  void logout() {
    _currentUsername = null;
    notifyListeners();
  }

  // ลบบัญชีผู้ใช้งาน
  void deleteAccount(String username) {
    _accounts.remove(username);
    if (_currentUsername == username) {
      _currentUsername = null;
    }
    notifyListeners();
  }

  // บันทึกข้อมูลแบบสอบถามของบัญชีปัจจุบัน
  void completeOnboarding({
    required String name,
    required double height,
    required double weight,
    required int age,
    required String gender,
    required WeightLossProgram program,
  }) {
    if (currentAccount != null) {
      currentAccount!.profile = UserProfile(
        name: name.isNotEmpty ? name : currentAccount!.username,
        height: height,
        weight: weight,
        age: age,
        gender: gender,
        program: program,
      );
      currentAccount!.hasCompletedOnboarding = true;
      notifyListeners();
    }
  }

  void addIngredient(IngredientItem item) {
    if (currentAccount != null) {
      currentAccount!.currentMealIngredients.add(item);
      notifyListeners();
    }
  }

  void removeIngredient(int index) {
    if (currentAccount != null && index >= 0 && index < currentAccount!.currentMealIngredients.length) {
      currentAccount!.currentMealIngredients.removeAt(index);
      notifyListeners();
    }
  }

  void clearCurrentMeal() {
    if (currentAccount != null) {
      currentAccount!.currentMealIngredients.clear();
      notifyListeners();
    }
  }

  void updateProfile({
    String? name,
    String? photoUrl,
    double? height,
    double? weight,
    int? age,
    String? gender,
    WeightLossProgram? program,
  }) {
    final prof = userProfile;
    if (prof != null) {
      if (name != null) prof.name = name;
      if (photoUrl != null) prof.photoUrl = photoUrl;
      if (height != null) prof.height = height;
      if (weight != null) prof.weight = weight;
      if (age != null) prof.age = age;
      if (gender != null) prof.gender = gender;
      if (program != null) prof.program = program;
      notifyListeners();
    }
  }
}