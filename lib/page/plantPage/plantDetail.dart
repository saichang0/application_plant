import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/controller/product/addItem.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/model/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/product/productcontroller.dart';

class PlantDetailNotifier extends StateNotifier<AsyncValue<Plant?>> {
  PlantDetailNotifier() : super(const AsyncValue.loading());

  Future<void> fetchPlant(String plantId, BuildContext context) async {
    state = const AsyncValue.loading();

    try {
      final result = await ProductController.fetchProduct(
        id: plantId,
        context: context,
      );
      print('Fetch plant result: $result');

      if (result != null && result['status'] == true && result['data'] is Map) {
        final productData = result['data'];
        print('Plant response data: $productData');

        final plant = Plant.fromGraphQL(productData);
        state = AsyncValue.data(plant);
      } else {
        state = AsyncValue.data(null);
        print('API returned error or null data');
      }
    } catch (e, stackTrace) {
      print('Error fetching plant: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void updateFavorite(bool isFavorite) {
    state.whenData((plant) {
      if (plant != null) {
        state = AsyncValue.data(plant.copyWith(isFavorite: isFavorite));
      }
    });
  }
}

final plantDetailProvider =
    StateNotifierProvider.family<
      PlantDetailNotifier,
      AsyncValue<Plant?>,
      String
    >((ref, plantId) => PlantDetailNotifier());

final plantQuantityProvider = StateProvider.family<int, String>(
  (ref, plantId) => 1,
);

final currentImageIndexProvider = StateProvider<int>((ref) => 0);

class PlantDetailPage extends ConsumerStatefulWidget {
  const PlantDetailPage({Key? key, required this.plantId}) : super(key: key);
  final String plantId;

  @override
  ConsumerState<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends ConsumerState<PlantDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _favoriteController;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _favoriteController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isTogglingFavorite = false;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(plantDetailProvider(widget.plantId).notifier)
          .fetchPlant(widget.plantId, context);
    });
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  void _playFavoriteAnimation() {
    setState(() {
      _isTogglingFavorite = true;
    });
    _favoriteController.forward(from: 0.0);
  }

  Future<void> _handleFavoriteTap(bool currentFavoriteState) async {
    if (_isTogglingFavorite) {
      return;
    }
    // Optimistically update the UI
    final newFavoriteState = !currentFavoriteState;
    ref
        .read(plantDetailProvider(widget.plantId).notifier)
        .updateFavorite(newFavoriteState);

    // Play animation if adding to favorites
    if (newFavoriteState) {
      _playFavoriteAnimation();
    } else {
      setState(() {
        _isTogglingFavorite = false;
      });
    }

    try {
      final result = await ProductController.togglewishlist(
        productId: widget.plantId,
        context: context,
      );
      if (result['status'] == true) {
        final data = result['data'];
        final isFavorite = data != null && data['isFavorite'] == true;

        // Update with server response
        ref
            .read(plantDetailProvider(widget.plantId).notifier)
            .updateFavorite(isFavorite);

        // If removing from favorites, stop animation immediately
        if (!isFavorite) {
          _favoriteController.reset();
          setState(() {
            _isTogglingFavorite = false;
          });
        }
      } else {
        // Revert on failure
        ref
            .read(plantDetailProvider(widget.plantId).notifier)
            .updateFavorite(currentFavoriteState);

        setState(() {
          _isTogglingFavorite = false;
        });
        _favoriteController.reset();
      }
    } catch (e) {
      ref
          .read(plantDetailProvider(widget.plantId).notifier)
          .updateFavorite(currentFavoriteState);

      setState(() {
        _isTogglingFavorite = false;
      });
      _favoriteController.reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantAsync = ref.watch(plantDetailProvider(widget.plantId));
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: plantAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: ColorConstants.buttonColor),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(plantDetailProvider(widget.plantId).notifier)
                      .fetchPlant(widget.plantId, context);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (plant) {
          if (plant == null) {
            return const Center(child: Text('Plant not found'));
          }
          final id = plant.id;
          final images = plant.images;
          final quantity = ref.watch(plantQuantityProvider(widget.plantId));
          final totalPrice = plant.price * quantity;
          final isFavorite = plant.isFavorite;
          final formattedPrice = NumberFormat(
            '#,###',
            'en_US',
          ).format(totalPrice).replaceAll(',', '.');

          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageSection(context, ref, plant, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plant.name,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                      _buildFavoriteButton(isFavorite),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildRatingSection(plant, isDark),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isDark
                                          ? Colors.white
                                          : Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    plant.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Color(0xFF999999),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildQuantitySection(
                                    ref,
                                    widget.plantId,
                                    quantity,
                                    isDark,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(
                      context,
                      formattedPrice,
                      plant.name,
                      quantity,
                      images,
                      plant.price,
                      id,
                      isDark,
                    ),
                  ],
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteButton(bool isFavorite) {
    return GestureDetector(
      onTap: () => _handleFavoriteTap(isFavorite),
      child: Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        child: _isTogglingFavorite && isFavorite
            ? ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  ColorConstants.buttonColor,
                  BlendMode.srcATop,
                ),
                child: Lottie.asset(
                  'assets/animations/Love Animation with Particle.json',
                  controller: _favoriteController,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  repeat: false,
                ),
              )
            : Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: ColorConstants.buttonColor,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    WidgetRef ref,
    Plant plant,
    isDark,
  ) {
    return Container(
      height: 400,
      width: double.infinity,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Image.network(
        plant.images,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: isDark ? Colors.black : Colors.grey[200],
            child: const Icon(
              Icons.local_florist,
              size: 100,
              color: ColorConstants.buttonColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingSection(Plant plant, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ColorConstants.buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '1258 Sold',
            style: TextStyle(
              color: ColorConstants.buttonColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.star, color: ColorConstants.iconColor, size: 20),
        const SizedBox(width: 4),
        Text(
          '${plant.rating} ⭐',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Color(0xFF666666),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${plant.reviewCount} reviews)',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection(
    WidgetRef ref,
    String plantId,
    int quantity,
    bool isDark,
  ) {
    final canDecrease = quantity >= 2;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: canDecrease
                  ? () =>
                        ref
                                .read(plantQuantityProvider(plantId).notifier)
                                .state =
                            quantity - 1
                  : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: canDecrease
                      ? ColorConstants.buttonColor
                      : ColorConstants.buttonColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.remove, color: Colors.white, size: 20),
              ),
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  ref.read(plantQuantityProvider(plantId).notifier).state =
                      quantity + 1,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ColorConstants.buttonColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    String formattedPrice,
    String plantName,
    int quantity,
    String image,
    double price,
    String id,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total price',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white : Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₭ $formattedPrice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(width: 50),
          Expanded(
            child: ElevatedButton(
              onPressed: () => {
                ref
                    .read(cartProvider.notifier)
                    .addItem(
                      name: plantName,
                      image: image,
                      price: price,
                      quantity: quantity,
                      productId: id,
                    ),
                // ToastHelper.showSuccess(
                //   context,
                //   "Success",
                //   "$plantName added to cart!",
                // ),
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
