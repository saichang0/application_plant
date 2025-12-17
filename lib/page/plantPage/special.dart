import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/model/plant.dart';
import 'package:plant_aplication/page/plantPage/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:plant_aplication/page/widget/plantSearch.dart';
import 'package:plant_aplication/page/plantPage/widget/plantcardWidget.dart';
import 'package:plant_aplication/controller/product/productcontroller.dart';

final SpecialCategoryProvider = StateProvider<String>((ref) => 'All');
final SpecialProductsProvider =
    StateNotifierProvider<SpecialNotifier, AsyncValue<List<Plant>>>(
      (ref) => SpecialNotifier(),
    );

class SpecialNotifier extends StateNotifier<AsyncValue<List<Plant>>> {
  SpecialNotifier() : super(const AsyncLoading()) {
    loadSpecial();
  }

  Future<void> loadSpecial() async {
    try {
      state = const AsyncLoading();

      final data = await ProductController.queryProducts(isSpecialOffer: true);
      print('🔥 Special Offers Raw Data: $data');
      final plants = data.map((productMap) {
        return Plant.fromGraphQL(productMap);
      }).toList();
      print('🔥 Special Offers Converted: ${plants.length} plants');
      state = AsyncData(plants);
    } catch (e, st) {
      print('❌ Error loading special offers: $e');
      print(st);
      state = AsyncError(e, st);
    }
  }

  void updateFavorite(String productId, bool isFavorite) {
    state.whenData((plants) {
      final updatedPlants = plants.map((p) {
        if (p.id == productId) {
          return p.copyWith(isFavorite: isFavorite);
        }
        return p;
      }).toList();
      state = AsyncData(updatedPlants);
    });
  }

  Future<void> refresh() async {
    await loadSpecial();
  }
}

class SpecialOffersPage extends ConsumerStatefulWidget {
  const SpecialOffersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SpecialOffersPage> createState() => _SpecialOffersPageState();
}

class _SpecialOffersPageState extends ConsumerState<SpecialOffersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(SpecialProductsProvider.notifier).loadSpecial();
    });
  }

  Future<void> _handleFavoriteToggle(
    String productId,
    bool currentState,
  ) async {
    try {
      final result = await ProductController.togglewishlist(
        productId: productId,
        context: context,
      );

      final statusValue = result['status'];
      final bool isSuccess =
          statusValue == true ||
          (statusValue is String && statusValue.toLowerCase() == 'true');

      if (isSuccess) {
        final tag =
            result['tag']?.toString().toLowerCase() ??
            result['message']?.toString().toLowerCase() ??
            '';
        final isFavorite = tag.contains('added');
        ref
            .read(SpecialProductsProvider.notifier)
            .updateFavorite(productId, isFavorite);
        ref
            .read(productsProvider.notifier)
            .updateFavorite(productId, isFavorite);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    await ref.read(SpecialProductsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final SpecialAsync = ref.watch(SpecialProductsProvider);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: CustomRefreshIndicator(
        onRefresh: _handleRefresh,
        offsetToArmed: 100.0,

        builder: (context, child, controller) {
          final isAnimating =
              controller.state == IndicatorState.dragging ||
              controller.state == IndicatorState.armed ||
              controller.state == IndicatorState.loading;

          final scale = 0.8 + (controller.value * 0.6).clamp(0.0, 0.6);

          return AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Stack(
                children: [
                  child,
                  if (controller.value > 0)
                    Positioned(
                      top: 140 + (controller.value * 50).clamp(0.0, 80.0),
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: controller.value.clamp(0.0, 1.0),
                        child: Center(
                          child: Transform.scale(
                            scale: scale,
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: Lottie.asset(
                                'assets/animations/water drop.json',
                                repeat: isAnimating,
                                animate: true,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(isDark),
            SpecialAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error loading Special')),
              ),
              data: (_) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            if (SpecialAsync is AsyncData)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  height: 56,
                  child: _buildStickyCategoryChips(isDark),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (SpecialAsync is AsyncData)
              _buildSpecialGrid(SpecialAsync, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? Colors.black : Colors.white,
      surfaceTintColor: isDark ? Colors.black : Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My Special',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlantSearchPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStickyCategoryChips(bool isDark) {
    final selectedCategory = ref.watch(SpecialCategoryProvider);
    final categories = ['All', 'Monstera', 'Aloe', 'Palm', 'Jade'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: isDark ? Colors.black : Colors.white,
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == selectedCategory;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(SpecialCategoryProvider.notifier).state = category;
                },
                backgroundColor: isDark ? Colors.black : Colors.white,
                selectedColor: ColorConstants.secondaryColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : ColorConstants.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
                side: const BorderSide(color: ColorConstants.secondaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                showCheckmark: false,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSpecialGrid(AsyncValue<List<Plant>> SpecialAsync, bool isDark) {
    final selectedCategory = ref.watch(SpecialCategoryProvider);

    return SpecialAsync.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Text('Error loading Special')),
      ),
      data: (plants) {
        final filteredPlants = selectedCategory == 'All'
            ? plants
            : plants.where((plant) {
                // add category logic later
                return true;
              }).toList();

        if (filteredPlants.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 400,
              margin: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: isDark ? Colors.white : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Special is empty',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final plant = filteredPlants[index];
              return PlantCard(
                key: ValueKey(plant.id),
                plant: plant,
                onFavoritePressed: () =>
                    _handleFavoriteToggle(plant.id, plant.isFavorite),
              );
            }, childCount: filteredPlants.length),
          ),
        );
      },
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bool isSticky = overlapsContent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      color: isSticky ? Colors.white : Colors.grey[50],
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.height != height;
  }
}
