# Quick Fix for AppProvider Listener

Replace the listener block in lib/providers/app_provider.dart (around line 286-320):

```
    // Listen to auth state changes FIRST (source of truth)
    _authService.authStateChanges().listen((app_user.User? user) async {
      if (user == null) {
        _currentUser = null;
        _isAuthenticated = false;
        await prefs.remove('isAuthenticated');
        notifyListeners();
        return;
      }

      _currentUser = user;
      _isAuthenticated = true;
      await prefs.setBool('isAuthenticated', true);
      notifyListeners();
    });
```

Then run `flutter pub get && flutter run`

