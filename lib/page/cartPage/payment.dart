import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant_aplication/constant/apiConst.dart';
import 'package:plant_aplication/services/authStorage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/constant/payment.dart';
import 'package:plant_aplication/constant/shipping.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/controller/order/ordercontroller.dart';
import 'package:plant_aplication/controller/product/addItem.dart';
import 'package:plant_aplication/until/appTranslate.dart';
import 'package:plant_aplication/model/address.dart';
import 'package:plant_aplication/page/cartPage/shipping.dart';
import 'package:plant_aplication/until/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

final selectedPaymentIndexProvider = StateProvider<int?>((ref) => 0);
final uploadedPaymentProofProvider = StateProvider<File?>((ref) => null);

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Show QR Code Dialog
  void _showQRCodeDialog(BuildContext context) {
    final language = ref.read(languageProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'scan_qr_to_pay'.tr(language),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'scan_qr_description'.tr(language),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 20),

                // QR Code Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/Qrcode.jpg',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 280,
                        height: 280,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code,
                              size: 64,
                              color: Color(0xFF00D9A3),
                            ),
                            const SizedBox(height: 8),
                            Text('qr_image_not_available'.tr(language)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Download Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadQRCode(context),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: Text(
                      'download_qr_code'.tr(language),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9A3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'close'.tr(language),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Download QR Code
  Future<void> _downloadQRCode(BuildContext context) async {
    final language = ref.read(languageProvider);
    try {
      // Request storage permission
      PermissionStatus status;
      try {
        status = await Permission.storage.request();
      } on MissingPluginException catch (_) {
        // Permission plugin not available (e.g., running in environment without plugins)
        status = PermissionStatus.granted;
      }

      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('storage_permission_required'.tr(language))),
        );
        return;
      }

      // Get the directory for saving
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        // Copy the file. If the source file doesn't exist, try to copy the bundled asset.
        final String path = '${directory.path}/payment_qr_code.png';
        final File sourceFile = File(
          '/mnt/user-data/uploads/1766845919097_image.png',
        );

        if (await sourceFile.exists()) {
          await sourceFile.copy(path);
        } else {
          try {
            final ByteData data = await rootBundle.load(
              'assets/images/6ed93576-4b5b-435b-afec-99cb2100fcb7.jpg',
            );
            final bytes = data.buffer.asUint8List();
            await File(path).writeAsBytes(bytes);
          } catch (e) {
            print('e: $e');
            Navigator.of(context).pop(); // Close dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('qr_image_save_unavailable'.tr(language)),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        Navigator.of(context).pop(); // Close dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'qr_code_saved_to'.tr(language).replaceFirst('{path}', path),
            ),
            backgroundColor: const Color(0xFF00D9A3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('e: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'failed_to_download'
                .tr(language)
                .replaceFirst('{error}', e.toString()),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show Upload Payment Proof Dialog
  void _showUploadProofDialog(BuildContext context) {
    final language = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.upload_file,
                  size: 60,
                  color: Color(0xFF00D9A3),
                ),
                const SizedBox(height: 16),
                Text(
                  'upload_payment_proof'.tr(language),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'upload_proof_description'.tr(language),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: Text(
                          'camera'.tr(language),
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D9A3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        label: Text(
                          'gallery'.tr(language),
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D9A3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr(language),
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Pick Image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        await Permission.camera.request();
      } else {
        await Permission.photos.request();
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      ref.read(uploadedPaymentProofProvider.notifier).state = File(image.path);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedPaymentIndexProvider);
    final uploadedProof = ref.watch(uploadedPaymentProofProvider);
    final paymentMethods = PaymentMethodConstants.paymentMethods;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Color(0xFF1A1A1A),
            ),
          ),
        ),
        title: Text(
          'payment_methods'.tr(language),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'select_payment_method'.tr(language),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(30 * (1 - value), 0),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PaymentMethodCard(
                      method: paymentMethods[index],
                      isSelected: selectedIndex == index,
                      onTap: () {
                        ref.read(selectedPaymentIndexProvider.notifier).state =
                            index;
                        // Show QR code dialog when payment method is selected
                        _showQRCodeDialog(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Upload Payment Proof Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: uploadedProof != null
                      ? const Color(0xFF00D9A3)
                      : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        uploadedProof != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        color: uploadedProof != null
                            ? const Color(0xFF00D9A3)
                            : const Color(0xFF666666),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          uploadedProof != null
                              ? 'payment_proof_uploaded'.tr(language)
                              : 'upload_payment_proof_required'.tr(language),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: uploadedProof != null
                                ? const Color(0xFF00D9A3)
                                : (isDark ? Colors.white : Color(0xFF1A1A1A)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (uploadedProof != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        uploadedProof,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showUploadProofDialog(context),
                      icon: Icon(
                        uploadedProof != null
                            ? Icons.change_circle
                            : Icons.upload,
                        color: const Color(0xFF00D9A3),
                      ),
                      label: Text(
                        uploadedProof != null
                            ? 'change_image'.tr(language)
                            : 'upload_image'.tr(language),
                        style: const TextStyle(
                          color: Color(0xFF00D9A3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Color(0xFF00D9A3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm Payment Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: GestureDetector(
                onTap: uploadedProof == null
                    ? () {
                        // Show error if no image uploaded
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'please_upload_proof_first'.tr(language),
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : () async {
                        final shippingIndex = ref.read(
                          selectedShippingIndexProvider,
                        );
                        final paymentIndex =
                            ref.read(selectedPaymentIndexProvider) ?? 0;
                        final cartItems = ref.read(cartProvider);
                        final selectedShipping =
                            ShippingConstants.shippingOptions[shippingIndex];
                        final selectedPayment =
                            PaymentMethodConstants.paymentMethods[paymentIndex];

                        // Upload slip image to the backend /upload endpoint (Cloudinary)
                        String? slipImageUrl;
                        try {
                          final token = await AuthStorage.getAccessToken();
                          final request = http.MultipartRequest(
                            'POST',
                            Uri.parse(ApiConstants.uploadUrl),
                          );
                          if (token != null && token.isNotEmpty) {
                            request.headers['Authorization'] = 'Bearer $token';
                          }
                          request.files.add(
                            await http.MultipartFile.fromPath(
                              'file',
                              uploadedProof.path,
                            ),
                          );
                          final streamed = await request.send();
                          final body = await streamed.stream.bytesToString();
                          if (streamed.statusCode != 200) {
                            throw Exception(
                              'Upload failed (${streamed.statusCode}): $body',
                            );
                          }
                          final decoded =
                              jsonDecode(body) as Map<String, dynamic>;
                          slipImageUrl = decoded['data']?['url'] as String?;
                          if (slipImageUrl == null || slipImageUrl.isEmpty) {
                            throw Exception('No URL returned from /upload');
                          }
                          debugPrint('SLIP IMAGE URL => $slipImageUrl');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'failed_to_upload_slip'
                                    .tr(language)
                                    .replaceFirst('{error}', e.toString()),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final total = cartItems.fold<double>(
                          0,
                          (sum, item) => sum + item.price * item.quantity,
                        );

                        final shippingBranch = ref.read(
                          selectedShippingBranchProvider,
                        );
                        final selectedAddress = ref.read(
                          selectedAddressProvider,
                        );

                        final input = {
                          "customerAddressId": selectedAddress?.id,
                          "deliveryService": selectedShipping.name,
                          "deliveryBranch": shippingBranch,
                          "paymentStatus": "PAID",
                          "payments": [
                            {
                              "paymentMethod": selectedPayment.name,
                              "currency": "LAK",
                              "amount": total,
                              "slipImageUrl": slipImageUrl,
                            },
                          ],
                          "orderItems": cartItems.map((item) {
                            return {
                              "productId": item.id,
                              "quantity": item.quantity,
                              "unitPrice": item.price,
                            };
                          }).toList(),
                        };

                        debugPrint(
                          "ORDER INPUT (without slip) => "
                          "${{...input, 'payments': (input['payments'] as List).map((p) {
                            final m = Map<String, dynamic>.from(p as Map);
                            m['slipImageUrl'] = m['slipImageUrl'] != null ? '<base64…>' : null;
                            return m;
                          }).toList()}}",
                        );

                        final result = await CreateOrderController.createOrder(
                          input: input,
                          context: context,
                        );

                        debugPrint("ORDER RESULT => $result");

                        if (result['status'] == true) {
                          ref.read(cartProvider.notifier).clearCart();
                          ref
                                  .read(selectedShippingIndexProvider.notifier)
                                  .state =
                              0;
                          ref
                                  .read(selectedPaymentIndexProvider.notifier)
                                  .state =
                              0;
                          ref
                                  .read(uploadedPaymentProofProvider.notifier)
                                  .state =
                              null;
                          ref
                                  .read(selectedShippingBranchProvider.notifier)
                                  .state =
                              '';
                          ToastHelper.showSuccess(
                            context,
                            'order_success_title'.tr(language),
                            'order_success_message'.tr(language),
                          );
                          Navigator.popUntil(context, (route) => route.isFirst);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ??
                                    'order_failed'.tr(language),
                              ),
                            ),
                          );
                        }
                      },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: uploadedProof != null
                        ? ColorConstants.gradient
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade400,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: uploadedProof != null
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00D9A3).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      uploadedProof != null
                          ? 'confirm_payment'.tr(language)
                          : 'upload_proof_to_continue'.tr(language),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodCard extends StatefulWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF00D9A3)
                : isDark
                ? Colors.grey[600]!
                : const Color(0xFFF0F0F0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? const Color(0xFF00D9A3).withOpacity(0.1)
                  : Colors.black.withOpacity(0.02),
              blurRadius: widget.isSelected ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Payment Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.method.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.method.icon != null
                  ? Icon(
                      widget.method.icon,
                      color: widget.method.iconColor,
                      size: 24,
                    )
                  : widget.method.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.method.image!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox(),
            ),
            const SizedBox(width: 16),

            // Payment Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (widget.method.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.method.subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Balance or Radio
            if (widget.method.balance != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FFF9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.method.balance!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D9A3),
                  ),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? const Color(0xFF00D9A3)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? const Color(0xFF00D9A3)
                        : const Color(0xFFD0D0D0),
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
