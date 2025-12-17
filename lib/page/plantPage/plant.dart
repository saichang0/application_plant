import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/model/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/page/plantPage/popular.dart';
import 'package:plant_aplication/page/plantPage/special.dart';
import 'package:plant_aplication/page/plantPage/wishlist.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/page/plantPage/plantDetail.dart';
import 'package:plant_aplication/page/plantPage/notification.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:plant_aplication/page/plantPage/widget/iconButtons.dart';
import 'package:plant_aplication/page/plantPage/widget/searchWidget.dart';
import 'package:plant_aplication/controller/product/productcontroller.dart';
import 'package:plant_aplication/controller/user/userProfileController.dart';
import 'package:plant_aplication/page/plantPage/widget/plantcardWidget.dart';
import 'package:plant_aplication/page/plantPage/widget/searchResultWidget.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final searchKeywordProvider = StateProvider<String>((ref) => '');
final currentPageProvider = StateProvider<int>((ref) => 1);
final itemsPerPageProvider = StateProvider<int>((ref) => 50);

final mostPopularProvider = FutureProvider<List<Plant>>((ref) async {
  try {
    final data = await ProductController.queryProducts();
    print("🔥 Raw Product Data: $data");

    final converted = data.map((item) => Plant.fromGraphQL(item)).toList();
    print("🔥 Converted Model: $converted");

    return converted;
  } catch (e, stack) {
    print("❌ Provider Exception: $e");
    print(stack);
    rethrow;
  }
});

final specialOffersProvider = FutureProvider<List<Plant>>((ref) async {
  final data = await ProductController.queryProducts();
  return data
      .where((item) => item['isSpecialOffer'] == true)
      .map((item) => Plant.fromGraphQL(item))
      .toList();
});

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Plant>>>(
      (ref) => ProductsNotifier(ref),
    );

final favoriteProductsProvider =
    StateNotifierProvider<FavoriteProductsNotifier, Set<String>>(
      (ref) => FavoriteProductsNotifier(),
    );

class FavoriteProductsNotifier extends StateNotifier<Set<String>> {
  FavoriteProductsNotifier() : super({});

  void setFavorite(String productId, bool isFavorite) {
    final updated = Set<String>.from(state);
    if (isFavorite) {
      updated.add(productId);
    } else {
      updated.remove(productId);
    }
    state = updated;
  }
}

class PlantStoreHomePage extends ConsumerStatefulWidget {
  const PlantStoreHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PlantStoreHomePage> createState() => _PlantStoreHomePageState();
}

class _PlantStoreHomePageState extends ConsumerState<PlantStoreHomePage> {
  final FocusNode expandedSearchFocus = FocusNode();
  final TextEditingController searchController = TextEditingController();

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning 👋";
    } else if (hour >= 12 && hour < 18) {
      return "Good Afternoon 🌞";
    } else if (hour >= 18 && hour < 23) {
      return "Good Evening 🌆";
    } else {
      return "Good Night 🌙";
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    ref.invalidate(mostPopularProvider);
    ref.invalidate(specialOffersProvider);
    ref.invalidate(productsProvider);
    await Future.delayed(const Duration(microseconds: 200));
  }

  Future<void> _handleSearch(String keyword) async {
    ref.read(searchKeywordProvider.notifier).state = keyword.trim();
    ref.read(currentPageProvider.notifier).state = 1;
    expandedSearchFocus.unfocus();
  }

  Future<void> _handleFavoriteToggle(
    BuildContext context,
    String productId,
  ) async {
    ref
        .read(favoriteProductsProvider.notifier)
        .setFavorite(
          productId,
          !ref.read(favoriteProductsProvider).contains(productId),
        );

    try {
      print("Toggling favorite for productId: $productId");
      final result = await ProductController.togglewishlist(
        productId: productId,
        context: context,
      );
      print("Toggle Favorite Result: $result");
      final isFavorite = result['data'] != null
          ? result['data']['isFavorite'] == true
          : false;
      ref
          .read(favoriteProductsProvider.notifier)
          .setFavorite(productId, isFavorite);

      ref.read(productsProvider.notifier).updateFavorite(productId, isFavorite);
    } catch (e) {
      print("Error toggling favorite: $e");
      ref
          .read(favoriteProductsProvider.notifier)
          .setFavorite(
            productId,
            ref.read(favoriteProductsProvider).contains(productId),
          );
    }
  }

  @override
  void dispose() {
    expandedSearchFocus.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specialOffers = ref.watch(specialOffersProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);
    final mostPopular = ref.watch(mostPopularProvider);
    final isSearching = searchKeyword.isNotEmpty;
    final isLoading = specialOffers.isLoading || mostPopular.isLoading;
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
            _buildAnimatedSliverAppBar(isDark),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (isSearching) ...[
              _buildSearchResults(isDark),
            ] else ...[
              _buildSpecialOffersSection(isDark),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              _buildMostPopularHeader(isDark),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  height: 56,
                  child: _buildStickyCategoryChips(isDark),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildMostPopularSliverGrid(isDark),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    final productsAsync = ref.watch(productsProvider);
    final favoriteProductIds = ref.watch(favoriteProductsProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);

    return productsAsync.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverSearchResultsWidget(
        plants: [],
        searchKeyword: searchKeyword,
        favoriteProductIds: favoriteProductIds,
        error: error,
        onClearSearch: _clearSearch,
        onFavoriteToggle: (productId) =>
            _handleFavoriteToggle(context, productId),
      ),
      data: (plants) => SliverSearchResultsWidget(
        plants: plants,
        searchKeyword: searchKeyword,
        favoriteProductIds: favoriteProductIds,
        onClearSearch: _clearSearch,
        onFavoriteToggle: (productId) =>
            _handleFavoriteToggle(context, productId),
      ),
    );
  }

  void _clearSearch() {
    searchController.clear();
    ref.read(searchKeywordProvider.notifier).state = '';
    ref.read(currentPageProvider.notifier).state = 1;
  }

  Widget _buildAnimatedSliverAppBar(bool isDark) {
    final userState = ref.watch(userProvider);

    final user = userState.asData?.value;
    final userName = user != null
        ? "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim()
        : 'Guest';
    final userAvatar = user?['profileImage'];

    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? Colors.black : Colors.white,
      surfaceTintColor: isDark ? Colors.black : Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double collapseRatio =
              ((constraints.maxHeight - kToolbarHeight) /
                      (140.0 - kToolbarHeight))
                  .clamp(0.0, 1.0);
          final bool isCollapsed = collapseRatio < 0.5;

          return FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: isCollapsed
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                : EdgeInsets.zero,
            background: Container(
              color: isDark ? Colors.black : Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildUserAvatar(userAvatar, isDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  getGreeting(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SearchWidget(
                        controller: searchController,
                        focusNode: expandedSearchFocus,
                        onChanged: (value) {},
                        onFilterPressed: () {
                          _handleSearch(searchController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: IgnorePointer(
              ignoring: !isCollapsed,
              child: AnimatedOpacity(
                opacity: isCollapsed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: SizedBox(
                    height: 46,
                    child: SearchWidget(
                      controller: searchController,
                      focusNode: expandedSearchFocus,
                      onChanged: (value) {},
                      onFilterPressed: () {
                        _handleSearch(searchController.text);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        HeaderActionButtons(
          onNotificationPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => NotificationPage()));
          },
          onFavoritePressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => WishlistPage()));
          },
        ),
      ],
    );
  }

  Widget _buildUserAvatar(String? userAvatar, bool isDark) {
    if (userAvatar != null && userAvatar.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(userAvatar),
        onBackgroundImageError: (_, __) {
          // Handle image loading error
        },
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.green.withOpacity(0.2),
      child: const Icon(Icons.person, color: Colors.green),
    );
  }

  Widget _buildMostPopularHeader(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Most Popular',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PopularPage()),
                );
              },
              child: Text(
                'See All',
                style: TextStyle(
                  color: isDark ? ColorConstants.secondaryColor : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialOffersSection(bool isDark) {
    final specialOffers = ref.watch(specialOffersProvider);
    final favoriteProductIds = ref.watch(favoriteProductsProvider);

    return specialOffers.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (error, stack) {
        print('Special Offers Error: $error');
        return SliverToBoxAdapter(
          child: Container(
            height: 100,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Unable to load special offers',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ),
        );
      },
      data: (plants) {
        if (plants.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Special Offers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SpecialOffersPage(),
                          ),
                        );
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: isDark
                              ? ColorConstants.secondaryColor
                              : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    final isFavorite =
                        favoriteProductIds.contains(plant.id) ||
                        plant.isFavorite;
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 180,
                        child: PlantCard(
                          key: ValueKey('special_${plant.id}'),
                          plant: plant.copyWith(isFavorite: isFavorite),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlantDetailPage(plantId: plant.id),
                              ),
                            );
                          },
                          onFavoritePressed: () async {
                            await _handleFavoriteToggle(
                              context,
                              plants[index].id,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyCategoryChips(bool isDark) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categories = ['All', 'Monstera', 'Aloe', 'Palm', 'Jade'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  ref.read(selectedCategoryProvider.notifier).state = category;
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

  Widget _buildMostPopularSliverGrid(bool isDark) {
    final mostPopular = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final favoriteProductIds = ref.watch(favoriteProductsProvider);

    return mostPopular.when(
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (error, stack) {
        print('Most Popular Error: $error');
        return SliverToBoxAdapter(
          child: Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load popular plants',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (plants) {
        final filteredPlants = selectedCategory == 'All'
            ? plants
            : plants.where((plant) {
                return true;
              }).toList();

        if (filteredPlants.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_florist,
                      size: 48,
                      color: isDark ? Colors.white : Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No plants found',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return PlantCard(
                plant: filteredPlants[index].copyWith(
                  isFavorite:
                      favoriteProductIds.contains(filteredPlants[index].id) ||
                      filteredPlants[index].isFavorite,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlantDetailPage(plantId: plants[index].id),
                    ),
                  );
                },
                onFavoritePressed: () async {
                  await _handleFavoriteToggle(
                    context,
                    filteredPlants[index].id,
                  );
                },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSticky = overlapsContent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      color: isSticky
          ? isDark
                ? Colors.black
                : Colors.white
          : isDark
          ? Colors.black
          : Colors.grey[50],
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.height != height;
  }
}

class ProductsNotifier extends StateNotifier<AsyncValue<List<Plant>>> {
  final Ref ref;

  ProductsNotifier(this.ref) : super(const AsyncLoading()) {
    loadProducts();

    // Listen to search keyword changes
    ref.listen(searchKeywordProvider, (previous, next) {
      loadProducts();
    });

    // Listen to page changes
    ref.listen(currentPageProvider, (previous, next) {
      loadProducts();
    });
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncLoading();

      final keyword = ref.read(searchKeywordProvider);
      final page = ref.read(currentPageProvider);
      final limit = ref.read(itemsPerPageProvider);

      final result = await ProductController.queryProducts(
        keyword: keyword.isEmpty ? null : keyword,
        page: page,
        limit: limit,
      );

      if (result.isNotEmpty) {
        final plants = result.map((e) => Plant.fromGraphQL(e)).toList();
        state = AsyncData(plants);
      } else {
        state = const AsyncData([]);
      }
    } catch (e, st) {
      print('❌ ProductsNotifier Error: $e');
      state = AsyncError(e, st);
    }
  }

  void updateFavorite(String productId, bool isFavorite) {
    state.whenData((plants) {
      state = AsyncData(
        plants
            .map(
              (p) => p.id == productId ? p.copyWith(isFavorite: isFavorite) : p,
            )
            .toList(),
      );
    });
  }
}
