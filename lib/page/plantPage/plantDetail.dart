import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/controller/product/addItem.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/model/plant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/until/appTranslate.dart';
import 'package:plant_aplication/controller/product/productcontroller.dart';
import 'package:plant_aplication/page/plantPage/plant.dart'
    show favoriteProductsProvider, productsProvider;
import 'package:plant_aplication/page/plantPage/wishlist.dart'
    show wishlistProductsProvider;
import 'package:plant_aplication/page/plantPage/popular.dart'
    show PopularProductsProvider;
import 'package:plant_aplication/page/plantPage/special.dart'
    show SpecialProductsProvider;

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
    _favoriteController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _isTogglingFavorite = false;
      });
    });
  }

  /// Keep the shared list-page state in sync so heart icons on the plant cards
  /// update in real time (no refresh) when the favorite is toggled here.
  void _syncFavoriteToLists(bool isFavorite) {
    ref
        .read(favoriteProductsProvider.notifier)
        .setFavorite(widget.plantId, isFavorite);
    ref.read(productsProvider.notifier).updateFavorite(widget.plantId, isFavorite);
    ref
        .read(PopularProductsProvider.notifier)
        .updateFavorite(widget.plantId, isFavorite);
    ref
        .read(SpecialProductsProvider.notifier)
        .updateFavorite(widget.plantId, isFavorite);
    ref
        .read(wishlistProductsProvider.notifier)
        .updateFavorite(widget.plantId, isFavorite);
  }

  Future<void> _handleFavoriteTap(bool currentFavoriteState) async {
    final newFavoriteState = !currentFavoriteState;

    // Only the "add to favorite" animation can be in progress and block a
    // repeat add. Removing must NEVER be blocked, otherwise tapping to unfavorite
    // while the heart animation is still playing does nothing and the green stays.
    if (newFavoriteState && _isTogglingFavorite) {
      return;
    }

    // Optimistically update the UI (detail page + shared list state)
    ref
        .read(plantDetailProvider(widget.plantId).notifier)
        .updateFavorite(newFavoriteState);
    _syncFavoriteToLists(newFavoriteState);

    // Play animation if adding to favorites; otherwise cancel it immediately so
    // the green filled heart disappears right away.
    if (newFavoriteState) {
      _playFavoriteAnimation();
    } else {
      _favoriteController.reset();
      setState(() {
        _isTogglingFavorite = false;
      });
    }

    try {
      final result = await ProductController.togglewishlist(
        productId: widget.plantId,
        context: context,
      );

      // ---- Debug logging: see exactly what the backend returns ----
      debugPrint('❤️ TOGGLE WISHLIST ===============================');
      debugPrint('❤️ tapped: current=$currentFavoriteState -> new=$newFavoriteState');
      debugPrint('❤️ raw result: $result');
      debugPrint('❤️ result["status"] = ${result['status']} (${result['status'].runtimeType})');
      debugPrint('❤️ result["data"]   = ${result['data']} (${result['data'].runtimeType})');

      final status = result['status'];
      // Treat only an explicit error as failure. Backend `status` may be a
      // String like "SUCCESS"/"ERROR", a number, or a bool — anything that is
      // not clearly an error counts as success.
      final isError =
          status == 'ERROR' ||
          status == false ||
          status == 'false' ||
          status == 'FAILED' ||
          status == 'ERR';

      debugPrint('❤️ isError = $isError');

      if (!isError) {
        // Prefer the server's reported isFavorite. If it isn't present, KEEP the
        // optimistic value — never flip the heart back on a successful toggle.
        final data = result['data'];
        bool isFavorite;
        if (data is Map && data['isFavorite'] != null) {
          isFavorite = data['isFavorite'] == true;
          debugPrint('❤️ using server isFavorite = $isFavorite');
        } else {
          isFavorite = newFavoriteState;
          debugPrint('❤️ no server isFavorite, keeping optimistic = $isFavorite');
        }

        ref
            .read(plantDetailProvider(widget.plantId).notifier)
            .updateFavorite(isFavorite);
        _syncFavoriteToLists(isFavorite);

        // If it ended up not favorited, make sure the green animation is gone.
        if (!isFavorite) {
          _favoriteController.reset();
          if (mounted) {
            setState(() {
              _isTogglingFavorite = false;
            });
          }
        }
      } else {
        debugPrint('❤️ REVERTING to $currentFavoriteState because server returned an error');
        // Revert on failure
        ref
            .read(plantDetailProvider(widget.plantId).notifier)
            .updateFavorite(currentFavoriteState);
        _syncFavoriteToLists(currentFavoriteState);

        _favoriteController.reset();
        if (mounted) {
          setState(() {
            _isTogglingFavorite = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❤️ EXCEPTION in toggle: $e');
      ref
          .read(plantDetailProvider(widget.plantId).notifier)
          .updateFavorite(currentFavoriteState);
      _syncFavoriteToLists(currentFavoriteState);

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
    final language = ref.watch(languageProvider);

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
                '${'error'.tr(language)}: ${error.toString()}',
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
                child: Text('retry'.tr(language)),
              ),
            ],
          ),
        ),
        data: (plant) {
          if (plant == null) {
            return Center(child: Text('plant_not_found'.tr(language)));
          }
          final id = plant.id;
          final images = plant.images;
          final quantity = ref.watch(plantQuantityProvider(widget.plantId));
          final totalPrice = plant.price * quantity;
          // Reflect the shared list state so the heart stays consistent with the
          // plant cards (e.g. if it was favorited from the list before opening).
          final favoriteIds = ref.watch(favoriteProductsProvider);
          final isFavorite = favoriteIds.contains(id) || plant.isFavorite;
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
                                  const SizedBox(height: 14),
                                  Text(
                                    'description'.tr(language),
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
                      plant.bankAccountImageUrl,
                      plant.ownerId,
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
        child: _isTogglingFavorite
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
    final language = ref.watch(languageProvider);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ColorConstants.buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '1258 ${'sold'.tr(language)}',
            style: const TextStyle(
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
          '(${plant.reviewCount} ${'reviews'.tr(language)})',
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
    final language = ref.watch(languageProvider);
    final canDecrease = quantity >= 2;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'quantity'.tr(language),
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
    String? bankImageUrl,
    String? ownerId,
  ) {
    final language = ref.watch(languageProvider);
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
                'total_price'.tr(language),
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
                      ownerId: ownerId,
                      bankAccountImageUrl: bankImageUrl,
                    ),
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to cart successfully'),
                    backgroundColor: ColorConstants.buttonColor,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'add_to_cart'.tr(language),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
