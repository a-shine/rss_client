import 'package:flutter/foundation.dart';

import '../../../data/repositories/user_repository/user_repository.dart';
import '../../../domain/models/user.dart';
import '../../../utils/result.dart';

class SignInViewModel extends ChangeNotifier {
  SignInViewModel(this._userRepository);

  final UserRepository _userRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;

    switch (result) {
      case Ok<User>():
        notifyListeners();
        return true;
      case Error<User>():
        _errorMessage = result.error.toString();
        notifyListeners();
        return false;
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.signUp(
      email: email,
      password: password,
    );

    _isLoading = false;

    switch (result) {
      case Ok<User>():
        notifyListeners();
        return true;
      case Error<User>():
        _errorMessage = result.error.toString();
        notifyListeners();
        return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
