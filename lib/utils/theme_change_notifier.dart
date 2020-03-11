import 'package:flutter/foundation.dart';


class ThemeChangeNotifier extends ChangeNotifier {
  void notifyChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}