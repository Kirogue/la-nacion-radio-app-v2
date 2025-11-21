import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // Eliminamos PageController porque ya no usamos PageView
  // final PageController _pageController = PageController();

  int get currentIndex => _currentIndex;
  // PageController get pageController => _pageController;

  void changeTab(int index) {
    if (_currentIndex == index) return;
    
    _currentIndex = index;
    // _pageController.jumpToPage(index); // Esto causaba el error "ScrollController not attached"
    notifyListeners();
  
    // Resetear pila de navegación si es necesario
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
}
