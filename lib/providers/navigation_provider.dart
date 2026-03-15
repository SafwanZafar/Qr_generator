import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _index        = 0;
  int _savedRefresh = 0;

  int get index        => _index;
  int get savedRefresh => _savedRefresh;

  void goTo(int index) {
    _index = index;
    if (index == 3) _savedRefresh++;
    notifyListeners();
  }

  void goToGenerator()  => goTo(1);
  void goToScanner()    => goTo(2);
  void goToSaved()      => goTo(3);
  void goToTemplates()  => goTo(4);

  void refreshSaved() {
    _savedRefresh++;
    notifyListeners();
  }
}