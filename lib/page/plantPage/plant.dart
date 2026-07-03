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
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/until/appTranslate.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');
final searchKeywordProvider = StateProvider<String>((ref) => '');
final currentPageProvider = StateProvider<int>((ref) => 1);
final itemsPerPageProvider = StateProvider<int>((ref) => 50);

final mostPopularProvider = FutureProvider<List<Plant>>((ref) async {
  final data = await ProductController.queryProducts(
    page: 1,
    limit: 100,
    isPopular: true,
  );

  return data.map((item) => Plant.fromGraphQL(item)).toList();
});

final specialOffersProvider = FutureProvider<List<Plant>>((ref) async {
  final data = await ProductController.queryProducts(
    page: 1,
    limit: 10,
    isSpecialOffer: true,
  );

  return data.map((item) => Plant.fromGraphQL(item)).toList();
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

  String getGreeting(String language) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'good_morning'.tr(language);
    } else if (hour >= 12 && hour < 18) {
      return 'good_afternoon'.tr(language);
    } else if (hour >= 18 && hour < 23) {
      return 'good_evening'.tr(language);
    } else {
      return 'good_night'.tr(language);
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

  /// Push a favorite change to every provider that renders heart icons so all
  /// pages (home lists, popular, special, wishlist) update in real time.
  void _syncFavoriteEverywhere(String productId, bool isFavorite) {
    ref
        .read(favoriteProductsProvider.notifier)
        .setFavorite(productId, isFavorite);
    ref.read(productsProvider.notifier).updateFavorite(productId, isFavorite);
    ref
        .read(PopularProductsProvider.notifier)
        .updateFavorite(productId, isFavorite);
    ref
        .read(SpecialProductsProvider.notifier)
        .updateFavorite(productId, isFavorite);
    ref
        .read(wishlistProductsProvider.notifier)
        .updateFavorite(productId, isFavorite);
  }

  Future<void> _handleFavoriteToggle(
    BuildContext context,
    String productId,
  ) async {
    final wasFavorite =
        ref.read(favoriteProductsProvider).contains(productId);
    final optimistic = !wasFavorite;

    // Optimistic update across all pages.
    _syncFavoriteEverywhere(productId, optimistic);

    try {
      final result = await ProductController.togglewishlist(
        productId: productId,
        context: context,
      );

      final status = result['status'];
      final isError =
          status == 'ERROR' ||
          status == false ||
          status == 'false' ||
          status == 'FAILED';

      if (isError) {
        // Revert to the previous state.
        _syncFavoriteEverywhere(productId, wasFavorite);
        return;
      }

      // Trust the server's value if present, otherwise keep the optimistic one.
      final data = result['data'];
      final bool isFavorite = data is Map && data['isFavorite'] != null
          ? data['isFavorite'] == true
          : optimistic;
      _syncFavoriteEverywhere(productId, isFavorite);
    } catch (e) {
      print("Error toggling favorite: $e");
      _syncFavoriteEverywhere(productId, wasFavorite);
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
    final language = ref.watch(languageProvider);

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
            _buildAnimatedSliverAppBar(isDark, language),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (isSearching) ...[
              _buildSearchResults(isDark),
            ] else ...[
              _buildSpecialOffersSection(isDark, language),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              _buildMostPopularHeader(isDark, language),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  height: 56,
                  child: _buildStickyCategoryChips(isDark, language),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildMostPopularSliverGrid(isDark, language),
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

  Widget _buildAnimatedSliverAppBar(bool isDark, String language) {
    final userState = ref.watch(userProvider);

    final user = userState.asData?.value;
    final userName = user != null
        ? "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim()
        : 'guest'.tr(language);
    final userAvatar = (user?['profileImageUrl'] ?? user?['profileImage'])
        as String?;

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
                                  getGreeting(language),
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

  Widget _buildMostPopularHeader(bool isDark, String language) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'most_popular'.tr(language),
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
                'see_all'.tr(language),
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

  Widget _buildSpecialOffersSection(bool isDark, String language) {
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
                'unable_to_load_special_offers'.tr(language),
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
                      'special_offers'.tr(language),
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
                        'see_all'.tr(language),
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

  Widget _buildStickyCategoryChips(bool isDark, String language) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final productsAsync = ref.watch(productsProvider);
    final plants = productsAsync.asData?.value ?? const <Plant>[];
    final unique = <String>{};
    for (final p in plants) {
      final name = p.categoryName;
      if (name != null && name.trim().isNotEmpty) unique.add(name);
    }
    final categories = ['All', ...unique];
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
                label: Text(category == 'All' ? 'all'.tr(language) : category),
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

  Widget _buildMostPopularSliverGrid(bool isDark, String language) {
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
                    'unable_to_load_popular_plants'.tr(language),
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
            : plants
                  .where((plant) => plant.categoryName == selectedCategory)
                  .toList();

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
                      'no_plants_found'.tr(language),
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
    return oldDelegate.height != height || oldDelegate.child != child;
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
