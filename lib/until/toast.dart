import 'package:flutter/material.dart';
import 'dart:math' as math;

class ToastHelper {
  static OverlayEntry? _currentOverlay;

  static void showToast({
    required BuildContext context,
    required String title,
    required String message,
    required Color primaryColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onPrimaryAction,
    String? primaryActionText,
    VoidCallback? onSecondaryAction,
    String? secondaryActionText,
    bool showLoading = false,
  }) {
    _currentOverlay?.remove();

    _currentOverlay = OverlayEntry(
      builder: (context) => _ToastModal(
        title: title,
        message: message,
        primaryColor: primaryColor,
        icon: icon,
        duration: duration,
        onPrimaryAction: onPrimaryAction,
        primaryActionText: primaryActionText,
        onSecondaryAction: onSecondaryAction,
        secondaryActionText: secondaryActionText,
        showLoading: showLoading,
        onClose: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void showError(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      primaryColor: const Color(0xFFF44336),
      icon: Icons.error_outline,
      onPrimaryAction: onRetry,
      primaryActionText: onRetry != null ? 'Retry' : 'Okay',
    );
  }

  static void showWarning(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onAction,
    String? actionText,
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      primaryColor: const Color(0xFFFFC107),
      icon: Icons.warning_amber_rounded,
      onPrimaryAction: onAction,
      primaryActionText: actionText ?? 'Okay',
    );
  }

  static void showSuccess(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onPrimaryAction,
    String? primaryActionText,
    VoidCallback? onSecondaryAction,
    String? secondaryActionText,
    bool showLoading = false,
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      primaryColor: const Color(0xFF00C853),
      icon: Icons.check,
      onPrimaryAction: onPrimaryAction,
      primaryActionText: primaryActionText,
      onSecondaryAction: onSecondaryAction,
      secondaryActionText: secondaryActionText,
      showLoading: showLoading,
    );
  }

  static void close() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _ToastModal extends StatefulWidget {
  final String title;
  final String message;
  final Color primaryColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionText;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionText;
  final bool showLoading;
  final VoidCallback onClose;

  const _ToastModal({
    required this.title,
    required this.message,
    required this.primaryColor,
    required this.icon,
    required this.duration,
    this.onPrimaryAction,
    this.primaryActionText,
    this.onSecondaryAction,
    this.secondaryActionText,
    this.showLoading = false,
    required this.onClose,
  });

  @override
  State<_ToastModal> createState() => _ToastModalState();
}

class _ToastModalState extends State<_ToastModal>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();
    _iconController.forward();
    _particleController.forward();

    if (widget.onPrimaryAction == null && widget.onSecondaryAction == null) {
      Future.delayed(widget.duration, () {
        if (mounted) dismiss();
      });
    }
  }

  void dismiss() async {
    await _fadeController.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _iconController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black54,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Icon with Particles
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Decorative particles
                          ...List.generate(8, (index) {
                            return AnimatedBuilder(
                              animation: _particleController,
                              builder: (context, child) {
                                final angle = (index * math.pi * 2) / 8;
                                final distance = 45 * _particleController.value;
                                final opacity = 1 - _particleController.value;

                                return Positioned(
                                  left: 60 + math.cos(angle) * distance - 4,
                                  top: 60 + math.sin(angle) * distance - 4,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: widget.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),

                          // Main circle
                          ScaleTransition(
                            scale: Tween<double>(begin: 0, end: 1).animate(
                              CurvedAnimation(
                                parent: _iconController,
                                curve: Curves.elasticOut,
                              ),
                            ),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: widget.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.primaryColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Message
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.6),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Loading spinner
                    if (widget.showLoading) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.primaryColor,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    ],

                    // Action buttons
                    if (widget.onPrimaryAction != null ||
                        widget.onSecondaryAction != null) ...[
                      const SizedBox(height: 24),

                      // Primary button
                      if (widget.onPrimaryAction != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onPrimaryAction!();
                              dismiss();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              widget.primaryActionText ?? 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      // Secondary button
                      if (widget.onSecondaryAction != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              widget.onSecondaryAction!();
                              dismiss();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: widget.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.secondaryActionText ?? 'Cancel',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
