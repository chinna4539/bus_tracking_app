import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  void updatePage(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}
