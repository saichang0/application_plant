import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:plant_aplication/model/plant.dart';
import 'package:plant_aplication/constant/colorConst.dart';

class PlantCard extends StatefulWidget {
  const PlantCard({
    Key? key,
    required this.plant,
    this.onFavoritePressed,
    this.onTap,
  }) : super(key: key);

  final Plant plant;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onTap;

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(PlantCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plant.isFavorite != widget.plant.isFavorite) {
      if (widget.plant.isFavorite) {
        _playFavoriteAnimation();
      } else {
        setState(() {
          _isAnimating = false;
        });
        _controller.reset();
      }
    }
  }

  void _playFavoriteAnimation() {
    setState(() {
      _isAnimating = true;
    });
    _controller.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _isAnimating = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFavoriteTap() {
    if (widget.onFavoritePressed != null) {
      widget.onFavoritePressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat(
      '#,###',
      'en_US',
    ).format(widget.plant.price).replaceAll(',', '.');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  // borderRadius: const BorderRadius.vertical(
                  //   top: Radius.circular(16),
                  // ),
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.plant.images,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    cacheHeight: 280,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: isDark ? Colors.black : Colors.grey[200],
                        child: const Icon(
                          Icons.local_florist,
                          size: 50,
                          color: ColorConstants.buttonColor,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: _handleFavoriteTap,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: _isAnimating
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                ColorConstants.buttonColor,
                                BlendMode.srcATop,
                              ),
                              child: Lottie.asset(
                                'assets/animations/Love Animation with Particle.json',
                                controller: _controller,
                                fit: BoxFit.contain,
                                repeat: false,
                              ),
                            )
                          : Icon(
                              widget.plant.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: ColorConstants.buttonColor,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plant.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: ColorConstants.secondaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.plant.rating.toString(),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "₭ $formattedPrice",
                          style: const TextStyle(
                            color: ColorConstants.secondaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
