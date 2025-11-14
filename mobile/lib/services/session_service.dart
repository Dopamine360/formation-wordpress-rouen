import 'package:flutter/material.dart';

class SessionService extends ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _referendumId;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get referendumId => _referendumId;
  bool get isAuthenticated => _accessToken != null;

  void storeTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  void selectReferendum(String referendumId) {
    _referendumId = referendumId;
    notifyListeners();
  }

  void clear() {
    _accessToken = null;
    _refreshToken = null;
    _referendumId = null;
    notifyListeners();
  }
}
