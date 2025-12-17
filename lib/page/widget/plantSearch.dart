import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/controller/product/productcontroller.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/page/plantPage/plant.dart';
import 'package:plant_aplication/page/plantPage/widget/searchResultWidget.dart';
import 'package:plant_aplication/page/plantPage/widget/searchWidget.dart';

class PlantSearchPage extends ConsumerStatefulWidget {
  const PlantSearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PlantSearchPage> createState() => _PlantSearchPageState();
}

class _PlantSearchPageState extends ConsumerState<PlantSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _expandedSearchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleSearch(String keyword) async {
    ref.read(searchKeywordProvider.notifier).state = keyword.trim();
    ref.read(currentPageProvider.notifier).state = 1;
    _expandedSearchFocus.unfocus();
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
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SearchWidget(
                    controller: _searchController,
                    focusNode: _expandedSearchFocus,
                    onChanged: (value) {},
                    onFilterPressed: () {
                      _handleSearch(_searchController.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(slivers: [_buildSearchResults(isDark)]),
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    final productsAsync = ref.watch(productsProvider);
    final favoriteProductIds = ref.watch(favoriteProductsProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);
    if (searchKeyword.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Search for plants',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a keyword to find plants',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
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
    _searchController.clear();
    ref.read(searchKeywordProvider.notifier).state = '';
    ref.read(currentPageProvider.notifier).state = 1;
  }
}
