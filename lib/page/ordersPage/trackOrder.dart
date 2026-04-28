import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/controller/order/ordercontroller.dart';
import 'package:plant_aplication/model/order.dart';
import 'package:plant_aplication/page/ordersPage/order.dart';
import 'package:plant_aplication/until/appTranslate.dart';

/// 4-stage order tracker.
///
/// Stage is derived from the parent sale's status (and the delivery row's
/// status as a tie-breaker between confirmed → shipping):
///   0  pending      -> customer just placed the order
///   1  confirmed    -> shop accepted the order
///   2  shipping     -> shop dispatched / delivery in progress
///   3  completed    -> customer confirmed receipt
class TrackOrderPage extends ConsumerStatefulWidget {
  final OrderItem order;

  const TrackOrderPage({Key? key, required this.order}) : super(key: key);

  @override
  ConsumerState<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends ConsumerState<TrackOrderPage> {
  bool _confirming = false;
  late OrderItem _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  int _stageFor(OrderItem order) {
    final s = order.status.toLowerCase();
    final d = order.deliveryStatus.toLowerCase();
    if (s == 'completed') return 3;
    if (s == 'cancelled' || s == 'canceled') return -1;
    if (s == 'shipping' ||
        s == 'shipped' ||
        d == 'shipping' ||
        d == 'shipped') return 2;
    if (s == 'confirmed') return 1;
    return 0;
  }

  bool _canConfirm(OrderItem order) {
    final stage = _stageFor(order);
    return stage == 1 || stage == 2;
  }

  Future<void> _onConfirmReceived(String lang) async {
    setState(() => _confirming = true);
    final result = await CreateOrderController.confirmReceived(
      orderId: _order.orderId,
    );
    if (!mounted) return;
    setState(() => _confirming = false);

    final ok = result['status'] == true;
    final msg = ok
        ? 'confirm_received_done'.tr(lang)
        : (result['message']?.toString() ?? 'Error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.red),
    );
    if (ok) {
      ref.invalidate(ordersProvider);
      // Locally bump status so the timeline reflects the change immediately.
      setState(() {
        _order = OrderItem(
          id: _order.id,
          name: _order.name,
          image: _order.image,
          quantity: _order.quantity,
          totalPrice: _order.totalPrice,
          status: 'completed',
          isCompleted: true,
          productId: _order.productId,
          orderId: _order.orderId,
          orderDate: _order.orderDate,
          completedAt: DateTime.now(),
          lineCount: _order.lineCount,
          deliveryStatus: 'delivered',
          deliveryService: _order.deliveryService,
          deliveryBranch: _order.deliveryBranch,
          trackingNumber: _order.trackingNumber,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final stage = _stageFor(_order);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'track_order'.tr(lang),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductCard(isDark),
            const SizedBox(height: 24),
            _buildTrackingTimeline(isDark, stage, lang),
            const SizedBox(height: 24),
            _buildStageDetails(isDark, stage, lang),
            const SizedBox(height: 24),
            if (_canConfirm(_order))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _confirming ? null : () => _onConfirmReceived(lang),
                    icon: _confirming
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(
                      'confirm_received'.tr(lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _order.image.isNotEmpty
                  ? Image.network(
                      _order.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.local_florist_rounded,
                        size: 40,
                        color: isDark ? Colors.grey[300] : Colors.grey[400],
                      ),
                    )
                  : Icon(
                      Icons.local_florist_rounded,
                      size: 40,
                      color: isDark ? Colors.grey[300] : Colors.grey[400],
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _order.name,
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
                  'Qty = ${_order.quantity}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_order.totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(bool isDark, int stage, String lang) {
    final steps = [
      (Icons.inventory_2_outlined, 'track_step_placed'.tr(lang)),
      (Icons.task_alt_outlined, 'track_step_confirmed'.tr(lang)),
      (Icons.local_shipping_outlined, 'track_step_shipping'.tr(lang)),
      (Icons.check_circle_outline, 'track_step_completed'.tr(lang)),
    ];

    String headline;
    if (stage < 0) {
      headline = 'stage_cancelled_msg'.tr(lang);
    } else if (stage == 0) {
      headline = 'stage_pending_msg'.tr(lang);
    } else if (stage == 1) {
      headline = 'stage_confirmed_msg'.tr(lang);
    } else if (stage == 2) {
      headline = 'stage_shipping_msg'.tr(lang);
    } else {
      headline = 'stage_completed_msg'.tr(lang);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _buildTimelineIcon(steps[i].$1, stage >= i, steps[i].$2),
                if (i != steps.length - 1)
                  _buildTimelineDivider(stage > i),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIcon(IconData icon, bool isActive, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive
                ? ColorConstants.primaryColor.withOpacity(0.12)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? ColorConstants.primaryColor : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? ColorConstants.primaryColor : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider(bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 2,
        color: isActive ? ColorConstants.primaryColor : Colors.grey[300],
      ),
    );
  }

  Widget _buildStageDetails(bool isDark, int stage, String lang) {
    final entries = <Map<String, dynamic>>[
      {
        'title': 'track_step_placed'.tr(lang),
        'subtitle': _formatDate(_order.orderDate),
        'reached': stage >= 0,
      },
      {
        'title': 'track_step_confirmed'.tr(lang),
        'subtitle': stage >= 1 ? 'stage_confirmed_msg'.tr(lang) : '',
        'reached': stage >= 1,
      },
      {
        'title': 'track_step_shipping'.tr(lang),
        'subtitle': _shippingSubtitle(lang, stage),
        'reached': stage >= 2,
      },
      {
        'title': 'track_step_completed'.tr(lang),
        'subtitle':
            stage >= 3 ? _formatDate(_order.completedAt) : '',
        'reached': stage >= 3,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_status'.tr(lang),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < entries.length; i++)
            _buildStatusRow(
              entries[i]['title'].toString().replaceAll('\n', ' '),
              entries[i]['subtitle'].toString(),
              entries[i]['reached'] as bool,
              i == entries.length - 1,
              isDark,
            ),
        ],
      ),
    );
  }

  String _shippingSubtitle(String lang, int stage) {
    if (stage < 2) return '';
    final parts = <String>[];
    if (_order.deliveryService.isNotEmpty) {
      parts.add('${'delivery_service'.tr(lang)}: ${_order.deliveryService}');
    }
    if (_order.deliveryBranch.isNotEmpty) {
      parts.add('${'branch'.tr(lang)}: ${_order.deliveryBranch}');
    }
    if (_order.trackingNumber.isNotEmpty) {
      parts.add('${'tracking_number'.tr(lang)}: ${_order.trackingNumber}');
    }
    return parts.isEmpty ? 'stage_shipping_msg'.tr(lang) : parts.join('  •  ');
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
  }

  Widget _buildStatusRow(
    String title,
    String subtitle,
    bool reached,
    bool isLast,
    bool isDark,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: reached ? ColorConstants.primaryColor : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reached ? Icons.check : Icons.radio_button_unchecked,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: reached
                        ? ColorConstants.primaryColor.withOpacity(0.4)
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: reached
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
