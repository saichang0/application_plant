import 'dart:async';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/model/order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/controller/order/ordercontroller.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/until/appTranslate.dart';
import 'package:plant_aplication/page/ordersPage/trackOrder.dart';

final ordersProvider = FutureProvider<List<OrderItem>>((ref) async {
  final orders = await CreateOrderController.fetchOrders();
  print('order $orders');
  List<OrderItem> allOrderItems = [];

  for (var order in orders) {
    if (order['orderItems'] != null) {
      final orderItems = order['orderItems'] as List;
      for (var item in orderItems) {
        final itemWithStatus = Map<String, dynamic>.from(item);
        itemWithStatus['status'] = order['status'] ?? 'Processing';
        allOrderItems.add(OrderItem.fromJson(itemWithStatus));
      }
    }
  }

  return allOrderItems;
});

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _animationController
          ..reset()
          ..forward();
      }
    });
    Future.microtask(() {
      ref.invalidate(ordersProvider);
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 900));
    ref.invalidate(ordersProvider);
    await ref.read(ordersProvider.future);
  }

  Future<void> _handleCreateReview({
    required String productId,
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    final language = ref.read(languageProvider);
    if (rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_select_rating'.tr(language)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final result = await CreateOrderController.createReview(
        productId: productId,
        orderId: orderId,
        rating: rating,
        comment: comment,
      );
      if (mounted) Navigator.pop(context); // close loading

      final ok = result.isNotEmpty && result.first['status'] == true;
      if (ok) {
        if (mounted) Navigator.pop(context); // close bottom sheet
        ref.invalidate(ordersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('review_submitted'.tr(language)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('failed_to_submit_review'.tr(language)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('failed_to_submit_review'.tr(language)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final isDark = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Text(
              'my_orders'.tr(language),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.search_rounded,
        //       color: isDark ? Colors.white : Colors.black,
        //     ),
        //     onPressed: () {
        //       // Implement search functionality
        //     },
        //   ),
        // ],
        bottom: TabBar(
          controller: _tabController,
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed) ||
                states.contains(WidgetState.focused) ||
                states.contains(WidgetState.hovered)) {
              return Colors.transparent;
            }
            return null;
          }),
          splashFactory: NoSplash.splashFactory,
          labelColor: ColorConstants.secondaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ColorConstants.secondaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(text: 'active'.tr(language)),
            Tab(text: 'completed'.tr(language)),
          ],
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          // Active = anything not finished yet (pending, confirmed, shipped, …).
          // Completed = ONLY orders whose status is literally "completed".
          final activeOrders = orders
              .where((order) => order.status.toLowerCase() != 'completed')
              .toList();
          final completedOrders = orders
              .where((order) => order.status.toLowerCase() == 'completed')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              activeOrders.isEmpty
                  ? _buildEmptyState('active', isDark, language)
                  : _buildOrdersList(
                      activeOrders,
                      isActive: true,
                      isDark: isDark,
                      language: language,
                    ),
              completedOrders.isEmpty
                  ? _buildEmptyState('completed', isDark, language)
                  : _buildOrdersList(
                      completedOrders,
                      isActive: false,
                      isDark: isDark,
                      language: language,
                    ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: ColorConstants.secondaryColor,
          ),
        ),
        error: (error, stack) => _buildErrorState(error, isDark, language),
      ),
    );
  }

  Widget _buildOrdersList(
    List<OrderItem> orders, {
    required bool isActive,
    required bool isDark,
    required String language,
  }) {
    final ordersAsync = ref.watch(ordersProvider);
    final isRefreshing = ordersAsync.isLoading || ordersAsync.isRefreshing;

    return CustomRefreshIndicator(
      onRefresh: _handleRefresh,
      offsetToArmed: 100.0,
      builder: (context, child, controller) {
        final isAnimating =
            controller.state == IndicatorState.dragging ||
            controller.state == IndicatorState.armed ||
            controller.state == IndicatorState.loading ||
            isRefreshing;

        final scale = 0.8 + (controller.value * 0.6).clamp(0.0, 0.6);

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Stack(
              children: [
                child,
                if (controller.value > 0 || isRefreshing)
                  Positioned(
                    top: 10 + (controller.value * 50).clamp(0.0, 80.0),
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: isRefreshing
                          ? 1.0
                          : controller.value.clamp(0.0, 1.0),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(
            orders[index],
            isActive: isActive,
            isDark: isDark,
            language: language,
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    OrderItem order, {
    required bool isActive,
    required bool isDark,
    required String language,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.grey.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: order.image.isNotEmpty
                  ? Image.network(
                      order.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: ColorConstants.secondaryColor,
                          ),
                        );
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 16),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${'qty'.tr(language)} = ${order.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                if (order.orderDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${'ordered_on'.tr(language)}: ${_formatDate(order.orderDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
                if (!isActive && order.completedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${'ready_on'.tr(language)}: ${_formatDate(order.completedAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.secondaryColor,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       '\$${order.totalPrice.toStringAsFixed(0)}',
          //       style: const TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         color: ColorConstants.secondaryColor,
          //       ),
          //     ),
          //     const SizedBox(height: 12),
          //     ElevatedButton(
          //       onPressed: () {
          //         if (isActive) {
          //           _trackOrder(order, isDark);
          //         } else {
          //           _leaveReview(order, isDark, language);
          //         }
          //       },
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: ColorConstants.buttonColor,
          //         foregroundColor: Colors.white,
          //         elevation: 0,
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 8,
          //         ),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //       ),
          //       child: Text(
          //         isActive
          //             ? 'track_order'.tr(language)
          //             : 'leave_a_review'.tr(language),
          //         style: const TextStyle(
          //           fontSize: 12,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  void _trackOrder(OrderItem order, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackOrderPage(order: order)),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.local_florist_rounded,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CREATED':
        return const Color(0xFF00D4AA);
      case 'SHIPPED':
        return Colors.blue;
      case 'COMPLETED':
      case 'DELIVERED':
        return const Color.fromARGB(255, 0, 212, 74);
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String type, bool isDark, String language) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty.json',
            width: 220,
            height: 220,
            controller: _animationController,
            repeat: false,
            onLoaded: (composition) {
              _animationController.duration = composition.duration;
              _animationController.forward();
            },
          ),
          const SizedBox(height: 24),
          Text(
            'no_orders_yet'.tr(language),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            type == 'active'
                ? 'no_active_orders'.tr(language)
                : 'no_completed_orders'.tr(language),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, bool isDark, String language) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'failed_to_load_orders'.tr(language),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'please_try_again'.tr(language),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(ordersProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text('retry'.tr(language)),
          ),
        ],
      ),
    );
  }

  void _leaveReview(OrderItem order, bool isDark, String language) {
    int selectedRating = 0;
    final TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.black : Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'leave_a_review'.tr(language),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: order.image.isNotEmpty
                                ? Image.network(
                                    order.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.local_florist_rounded,
                                        size: 30,
                                        color: Colors.grey[400],
                                      );
                                    },
                                  )
                                : Icon(
                                    Icons.local_florist_rounded,
                                    size: 30,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[400],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty = ${order.quantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00D4AA,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.status,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00D4AA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${order.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.buttonColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'how_is_your_order'.tr(language),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'please_give_rating_review'.tr(language),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: ColorConstants.buttonColor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ColorConstants.buttonColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: reviewController,
                      decoration: InputDecoration(
                        hintText: 'write_your_review_here'.tr(language),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: Icon(
                          Icons.edit_outlined,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : const Color(0xFFE8F5F3),
                            foregroundColor: ColorConstants.buttonColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'cancel'.tr(language),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            _handleCreateReview(
                              productId: order.productId,
                              orderId: order.orderId,
                              rating: selectedRating,
                              comment: reviewController.text.trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.buttonColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'submit'.tr(language),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
