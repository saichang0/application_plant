import 'package:plant_aplication/page/cartPage/cart.dart';
import 'package:plant_aplication/page/ordersPage/order.dart';
import 'package:plant_aplication/page/profilePage/profile.dart';

import 'animatedBottomNav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/page/plantPage/plant.dart';

// State class
class BottomNavState {
  final int currentIndex;

  BottomNavState({this.currentIndex = 0});

  BottomNavState copyWith({int? currentIndex}) {
    return BottomNavState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

// Notifier class
class BottomNavNotifier extends StateNotifier<BottomNavState> {
  BottomNavNotifier() : super(BottomNavState());

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

// Provider
final bottomNavProvider =
    StateNotifierProvider<BottomNavNotifier, BottomNavState>((ref) {
      return BottomNavNotifier();
    });

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavState = ref.watch(bottomNavProvider);
    final currentIndex = bottomNavState.currentIndex;

    final pages = [
      const PlantStoreHomePage(),
      const CartPage(),
      const OrdersPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentIndex],
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavProvider.notifier).setIndex(index);
        },
      ),
    );
  }
}
