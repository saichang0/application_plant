import 'package:flutter/material.dart';
import 'package:plant_aplication/model/order.dart';

class TrackOrderPage extends StatelessWidget {
  final OrderItem order;

  const TrackOrderPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Product Card
            _buildProductCard(),
            const SizedBox(height: 24),
            // Tracking Timeline
            _buildTrackingTimeline(),
            const SizedBox(height: 24),
            // Order Status Details
            _buildOrderStatusDetails(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
              color: const Color(0xFFF5F5F5),
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
                          size: 40,
                          color: Colors.grey[400],
                        );
                      },
                    )
                  : Icon(
                      Icons.local_florist_rounded,
                      size: 40,
                      color: Colors.grey[400],
                    ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty = ${order.quantity}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D4AA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineIcon(
                Icons.inventory_2_outlined,
                true,
                'Order\nPlaced',
              ),
              _buildTimelineDivider(true),
              _buildTimelineIcon(
                Icons.local_shipping_outlined,
                true,
                'In\nDelivery',
              ),
              _buildTimelineDivider(false),
              _buildTimelineIcon(
                Icons.airport_shuttle_outlined,
                false,
                'On the\nWay',
              ),
              _buildTimelineDivider(false),
              _buildTimelineIcon(
                Icons.check_circle_outline,
                false,
                'Delivered',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Packet In Delivery',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
                ? const Color(0xFF00D4AA).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF00D4AA) : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00D4AA) : Colors.grey[300],
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF00D4AA) : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider(bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: List.generate(
            5,
            (index) => Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF00D4AA) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusDetails() {
    final List<Map<String, dynamic>> statusDetails = [
      {
        'title': 'Order In Transit',
        'date': 'Dec 17',
        'time': '15:20 PM',
        'address': '32 Manchester Ave. Ringgold, GA 30736',
        'isActive': true,
      },
      {
        'title': 'Order ... Customs Port',
        'date': 'Dec 16',
        'time': '14:40 PM',
        'address': '4 Evergreen Street Lake Zurich, IL 60047',
        'isActive': true,
      },
      {
        'title': 'Orders are ... Shipped',
        'date': 'Dec 15',
        'time': '11:30 AM',
        'address': '9177 Hillcrest Street Wheeling, WV 26003',
        'isActive': true,
      },
      {
        'title': 'Order is in Packing',
        'date': 'Dec 15',
        'time': '10:25 AM',
        'address': '891 Glen Ridge St. Gainesville, VA 20155',
        'isActive': true,
      },
      {
        'title': 'Verified Payments',
        'date': 'Dec 15',
        'time': '10:04 AM',
        'address': '55 Summerhouse Dr. Apopka, FL 32703',
        'isActive': true,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...statusDetails.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isLast = index == statusDetails.length - 1;
            return _buildStatusItem(
              status['title'],
              status['date'],
              status['time'],
              status['address'],
              status['isActive'],
              isLast,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String title,
    String date,
    String time,
    String address,
    bool isActive,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF00D4AA) : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? const Color(0xFF00D4AA).withOpacity(0.3)
                        : Colors.transparent,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Status details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$title - $date',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
