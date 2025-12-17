import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/model/plant.dart';
import 'package:plant_aplication/page/plantPage/widget/plantcardWidget.dart';
import 'package:plant_aplication/page/plantPage/plantDetail.dart';

class SearchResultsWidget extends ConsumerWidget {
  final List<Plant> plants;
  final String searchKeyword;
  final Set<String> favoriteProductIds;
  final bool isLoading;
  final Object? error;
  final VoidCallback onClearSearch;
  final Future<void> Function(String productId) onFavoriteToggle;
  final int crossAxisCount;
  final double childAspectRatio;

  const SearchResultsWidget({
    Key? key,
    required this.plants,
    required this.searchKeyword,
    required this.favoriteProductIds,
    this.isLoading = false,
    this.error,
    required this.onClearSearch,
    required this.onFavoriteToggle,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.65,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return _buildErrorWidget();
    }

    return Column(
      children: [
        _buildSearchResultsHeader(context),
        const SizedBox(height: 16),
        _buildSearchResultsGrid(context),
      ],
    );
  }

  Widget _buildSearchResultsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Found ${plants.length} plants for "$searchKeyword"',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onClearSearch,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  /// Grid displaying search results
  Widget _buildSearchResultsGrid(BuildContext context) {
    if (plants.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          final isFavorite =
              favoriteProductIds.contains(plant.id) || plant.isFavorite;

          return PlantCard(
            key: ValueKey(plant.id),
            plant: plant.copyWith(isFavorite: isFavorite),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantDetailPage(plantId: plant.id),
                ),
              );
            },
            onFavoritePressed: () async {
              await onFavoriteToggle(plant.id);
            },
          );
        },
      ),
    );
  }

  /// Empty state when no results found
  Widget _buildEmptyState() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No plants found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load search results',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sliver version for use in CustomScrollView
class SliverSearchResultsWidget extends ConsumerWidget {
  final List<Plant> plants;
  final String searchKeyword;
  final Set<String> favoriteProductIds;
  final bool isLoading;
  final Object? error;
  final VoidCallback onClearSearch;
  final Future<void> Function(String productId) onFavoriteToggle;
  final int crossAxisCount;
  final double childAspectRatio;

  const SliverSearchResultsWidget({
    Key? key,
    required this.plants,
    required this.searchKeyword,
    required this.favoriteProductIds,
    this.isLoading = false,
    this.error,
    required this.onClearSearch,
    required this.onFavoriteToggle,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.65,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return SliverToBoxAdapter(child: _buildErrorWidget());
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSearchResultsHeader(context),
        const SizedBox(height: 16),
        _buildSearchResultsGrid(context),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildSearchResultsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Found ${plants.length} plants for "$searchKeyword"',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onClearSearch,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsGrid(BuildContext context) {
    if (plants.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          final isFavorite =
              favoriteProductIds.contains(plant.id) || plant.isFavorite;

          return PlantCard(
            key: ValueKey(plant.id),
            plant: plant.copyWith(isFavorite: isFavorite),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlantDetailPage(plantId: plant.id),
                ),
              );
            },
            onFavoritePressed: () async {
              await onFavoriteToggle(plant.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No plants found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to load search results',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
