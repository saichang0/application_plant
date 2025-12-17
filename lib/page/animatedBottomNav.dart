import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/controller/themeProvider.dart';

class AnimatedBottomNav extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AnimatedBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends ConsumerState<AnimatedBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  final List<String> _animationPaths = [
    'assets/animations/Home Icon Loading.json',
    'assets/animations/Shopping Cart.json',
    'assets/animations/Document OCR Scan.json',
    'assets/animations/Waving.json',
  ];

  final List<String> _labels = ['Home', 'Cart', 'Orders', 'Profile'];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      _animationPaths.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    for (var i = 0; i < _animationControllers.length; i++) {
      _animationControllers[i].value = 1.0;
    }
    _animationControllers[index].reset();
    _animationControllers[index].forward();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.black : Colors.white),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.black : Colors.white,
        unselectedItemColor: isDark ? Colors.white60 : Colors.grey,
        selectedItemColor: Color(0xFF007A4A),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: List.generate(_animationPaths.length, (index) {
          List<double> speeds = [1, 0.7, 0.5, 0.5];
          Color iconColor = widget.currentIndex == index
              ? Color(0xFF007A4A)
              : Colors.grey;
          return BottomNavigationBarItem(
            icon: SizedBox(
              width: 44,
              height: 44,
              child: Transform.scale(
                scale: index == 0 ? 0.75 : 1.0,
                child: Lottie.asset(
                  _animationPaths[index],
                  controller: _animationControllers[index],
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(['**'], value: iconColor),
                    ],
                  ),
                  onLoaded: (composition) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      _animationControllers[index].duration =
                          composition.duration * speeds[index];
                      _animationControllers[index].value = 1.0;
                    });
                  },
                ),
              ),
            ),
            label: _labels[index],
          );
        }),
      ),
    );
  }
}
