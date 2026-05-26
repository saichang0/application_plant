// Translation Helper Class
class AppTranslations {
  static Map<String, Map<String, String>> translations = {
    // Common
    'save': {'en': 'Save', 'lo': 'ບັນທຶກ'},
    'cancel': {'en': 'Cancel', 'lo': 'ຍົກເລີກ'},
    'edit': {'en': 'Edit', 'lo': 'ແກ້ໄຂ'},
    'delete': {'en': 'Delete', 'lo': 'ລຶບ'},
    'confirm': {'en': 'Confirm', 'lo': 'ຢືນຢັນ'},
    'back': {'en': 'Back', 'lo': 'ກັບຄືນ'},
    'next': {'en': 'Next', 'lo': 'ຖັດໄປ'},
    'done': {'en': 'Done', 'lo': 'ສຳເລັດ'},
    'loading': {'en': 'Loading...', 'lo': 'ກຳລັງໂຫລດ...'},
    'error': {'en': 'Error', 'lo': 'ຜິດພາດ'},
    'success': {'en': 'Success', 'lo': 'ສຳເລັດ'},

    // Profile
    'profile': {'en': 'Profile', 'lo': 'ໂປຣໄຟລ໌'},
    'edit_profile': {'en': 'Edit Profile', 'lo': 'ແກ້ໄຂໂປຣໄຟລ໌'},
    'address': {'en': 'Address', 'lo': 'ທີ່ຢູ່'},
    'notification': {'en': 'Notification', 'lo': 'ແຈ້ງການ'},
    'language': {'en': 'Language', 'lo': 'ພາສາ'},
    'lang_en': {'en': 'English (US)', 'lo': 'ອັງກິດ (US)'},
    'lang_lo': {'en': 'Lao', 'lo': 'ລາວ'},
    'dark_mode': {'en': 'Dark Mode', 'lo': 'ໂໝດມືດ'},
    'light_mode': {'en': 'Light Mode', 'lo': 'ໂໝດສະຫວ່າງ'},
    'logout': {'en': 'Logout', 'lo': 'ອອກຈາກລະບົບ'},
    'profile_details': {'en': 'Profile Details', 'lo': 'ລາຍລະອຽດຂໍ້ມູນສ່ວນຕົວ'},
    'first_name': {'en': 'First Name', 'lo': 'ຊື່'},
    'last_name': {'en': 'Last Name', 'lo': 'ນາມສະກຸນ'},
    'gender': {'en': 'Gender', 'lo': 'ສີເພິ່ນ'},
    'birthday': {'en': 'Birthday', 'lo': 'ວັນເກີດ'},
    'email': {'en': 'Email', 'lo': 'ອີເມວ'},
    'phone': {'en': 'Phone', 'lo': 'ເບີໂທ'},
    'password': {'en': 'Password', 'lo': 'ລະຫັດຜ່ານ'},
    'save_changes': {'en': 'Save Changes', 'lo': 'ບັນທຶກການປ່ຽນແປງ'},
    'profile_updated': {
      'en': 'Profile updated successfully',
      'lo': 'ອັບເດດຂໍ້ມູນສຳເລັດ',
    },
    'profile_update_failed': {
      'en': 'Failed to update profile',
      'lo': 'ອັບເດດຂໍ້ມູນບໍ່ສຳເລັດ',
    },
    'are_you_want_to_logout': {
      'en': 'Are you sure you want to logout?',
      'lo': 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການອອກຈາກລະບົບ?',
    },

    // Wishlist
    'wishlist': {'en': 'Wishlist', 'lo': 'ລາຍການທີ່ຕ້ອງການ'},
    'my_wishlist': {'en': 'My Wishlist', 'lo': 'ລາຍການສິ່ງທີ່ຢາກໄດ້'},

    // Settings
    'settings': {'en': 'Settings', 'lo': 'ການຕັ້ງຄ່າ'},
    'change_language': {'en': 'Change Language', 'lo': 'ປ່ຽນພາສາ'},
    'language_changed': {
      'en': 'Language changed successfully',
      'lo': 'ປ່ຽນພາສາສຳເລັດ',
    },

    // Plants
    'plants': {'en': 'Plants', 'lo': 'ພືດ'},
    'my_plants': {'en': 'My Plants', 'lo': 'ພືດຂອງຂ້ອຍ'},
    'add_plant': {'en': 'Add Plant', 'lo': 'ເພີ່ມພືດ'},
    'plant_name': {'en': 'Plant Name', 'lo': 'ຊື່ພືດ'},
    'plant_type': {'en': 'Plant Type', 'lo': 'ປະເພດພືດ'},
    'most_popular': {'en': 'Most Popular', 'lo': 'ນິຍົມທີ່ສຸດ'},
    'special_offers': {'en': 'Special Offers', 'lo': 'ຂໍ້ສະເໜີພິເສດ'},
    'my_special': {'en': 'My Special', 'lo': 'ພິເສດຂອງຂ້ອຍ'},
    'error_loading_special': {
      'en': 'Error loading Special',
      'lo': 'ໂຫຼດຂໍ້ສະເໜີພິເສດບໍ່ສຳເລັດ',
    },
    'special_empty': {
      'en': 'Your Special is empty',
      'lo': 'ບໍ່ມີຂໍ້ສະເໜີພິເສດ',
    },
    'see_all': {'en': 'See All', 'lo': 'ເບິ່ງທັງໝົດ'},
    'unable_to_load_special_offers': {
      'en': 'Unable to load special offers',
      'lo': 'ບໍ່ສາມາດໂຫຼດຂໍ້ສະເໜີພິເສດ',
    },
    'unable_to_load_popular_plants': {
      'en': 'Unable to load popular plants',
      'lo': 'ບໍ່ສາມາດໂຫຼດພືດນິຍົມ',
    },
    'my_popular': {'en': 'My Popular', 'lo': 'ນິຍົມຂອງຂ້ອຍ'},
    'popular_empty': {
      'en': 'Your popular list is empty',
      'lo': 'ລາຍການນິຍົມຂອງທ່ານວ່າງເປົ່າ',
    },
    'error_loading_popular': {
      'en': 'Error loading popular',
      'lo': 'ຜິດພາດໃນການໂຫຼດນິຍົມ',
    },
    'all': {'en': 'All', 'lo': 'ທັງໝົດ'},
    'search_results': {'en': 'Search Results', 'lo': 'ຜົນການຄົ້ນຫາ'},
    'found_plants_for_keyword': {
      'en': 'Found {count} plants for "{keyword}"',
      'lo': 'ພົບ {count} ພືດສຳລັບ "{keyword}"',
    },
    'try_searching_with_different_keywords': {
      'en': 'Try searching with different keywords',
      'lo': 'ລອງຄົ້ນຫາດ້ວຍຄຳສັບອື່ນ',
    },
    'unable_to_load_search_results': {
      'en': 'Unable to load search results',
      'lo': 'ບໍ່ສາມາດໂຫຼດຜົນການຄົ້ນຫາ',
    },

    // Auth
    'login': {'en': 'Login', 'lo': 'ເຂົ້າສູ່ລະບົບ'},
    'register': {'en': 'Register', 'lo': 'ລົງທະບຽນ'},
    'forgot_password': {'en': 'Forgot Password?', 'lo': 'ລືມລະຫັດຜ່ານ?'},

    // Navigation
    'home': {'en': 'Home', 'lo': 'ໜ້າຫຼັກ'},
    'cart': {'en': 'Cart', 'lo': 'ກະຕ່າ'},
    'orders': {'en': 'Orders', 'lo': 'ອໍເດີ'},
    'my_cart': {'en': 'My Cart', 'lo': 'ກະຕ່າຂອງຂ້ອຍ'},

    // Authentication
    'login_to_your_account': {
      'en': 'Login to Your Account',
      'lo': 'ເຂົ້າສູ່ລະບົບບັນຊີຂອງທ່ານ',
    },
    'this_field_is_required': {
      'en': 'This field is required',
      'lo': 'ຂໍ້ມູນນີ້ຈຳເປັນຕ້ອງໃສ່',
    },
    'remember_me': {'en': 'Remember me', 'lo': 'ຈື່ຂ້ອຍ'},
    'dont_have_account': {
      'en': "Don't have an account?",
      'lo': 'ຍັງບໍ່ມີບັນຊີ?',
    },
    'create_new_account': {'en': 'Create New Account', 'lo': 'ສ້າງບັນຊີໃໝ່'},
    'sign_up': {'en': 'Sign up', 'lo': 'ລົງທະບຽນ'},
    'already_have_account': {
      'en': 'Already have an account?',
      'lo': 'ມີບັນຊີແລ້ວ?',
    },
    'sign_in': {'en': 'Sign in', 'lo': 'ເຂົ້າສູ່ລະບົບ'},

    // Cart
    'remove_item': {'en': 'Remove Item', 'lo': 'ລຶບລາຍການອອກ'},
    'yes_remove': {'en': 'Yes, Remove', 'lo': 'ແມ່ນ, ລຶບອອກ'},
    'your_cart_is_empty': {
      'en': 'Your cart is empty',
      'lo': 'ກະຕ່າຂອງທ່ານວ່າງເປົ່າ',
    },
    'cart_empty_description': {
      'en':
          "You don't have any items added to your cart yet.\\nYou need to add items to your cart before\\ncheckout.",
      'lo':
          'ທ່ານຍັງບໍ່ໄດ້ເພີ່ມສິນຄ້າໃດໆລົງໃນກະຕ່າເທື່ອ.\\nທ່ານຕ້ອງເພີ່ມສິນຄ້າໃນກະຕ່າກ່ອນ\\nຈ່າຍເງິນ.',
    },
    'checkout': {'en': 'Checkout', 'lo': 'ຈ່າຍເງິນ'},
    'item': {'en': 'item', 'lo': 'ລາຍການ'},
    'items': {'en': 'items', 'lo': 'ລາຍການ'},
    'remove_from_cart': {'en': 'Remove from cart', 'lo': 'ລຶບອອກຈາກກະຕ່າ'},
    'added_to_cart': {'en': 'Added to cart', 'lo': 'ເພີ່ມໃນກະຕ່າແລ້ວ'},
    'continue_to_payment': {
      'en': 'Continue to Payment',
      'lo': 'ດຳເນີນການຊຳລະເງິນຕໍ່',
    },
    'order_list': {'en': 'Order List', 'lo': 'ລາຍຊື່ຄຳສັ່ງຊື້'},
    'shipping_name': {'en': 'Shipping Name', 'lo': 'ຊື່ຜູ້ຮັບ'},
    'full_address': {'en': 'Full Address', 'lo': 'ທີ່ຢູ່ເຕັມ'},
    'no_address_yet': {
      'en': 'No address yet. Please add one.',
      'lo': 'ຍັງບໍ່ມີທີ່ຢູ່. ກະລຸນາເພີ່ມທີ່ຢູ່.',
    },
    'add_new_address': {'en': 'Add New Address', 'lo': 'ເພີ່ມທີ່ຢູ່ໃໝ່'},
    'no_address_title': {'en': 'No Address', 'lo': 'ຍັງບໍ່ມີທີ່ຢູ່'},
    'please_add_address_first': {
      'en': 'Please add at least one address before proceeding.',
      'lo': 'ກະລຸນາເພີ່ມທີ່ຢູ່ຢ່າງໜ້ອຍ 1 ບ່ອນກ່ອນດຳເນີນການ.',
    },
    'no_default_address': {
      'en': 'No Default Address',
      'lo': 'ຍັງບໍ່ມີທີ່ຢູ່ເລີ່ມຕົ້ນ',
    },
    'please_select_default_address': {
      'en': 'Please select or add a default address before proceeding.',
      'lo': 'ກະລຸນາເລືອກ ຫຼື ເພີ່ມທີ່ຢູ່ເລີ່ມຕົ້ນກ່ອນດຳເນີນການ.',
    },
    'select_your_address': {
      'en': 'Select Your Address',
      'lo': 'ເລືອກທີ່ຢູ່ຂອງທ່ານ',
    },
    'province': {'en': 'Province', 'lo': 'ແຂວງ'},
    'select_province': {'en': 'Select Province', 'lo': 'ເລືອກແຂວງ'},
    'district': {'en': 'District', 'lo': 'ເມືອງ'},
    'select_district': {'en': 'Select District', 'lo': 'ເລືອກເມືອງ'},
    'village': {'en': 'Village', 'lo': 'ບ້ານ'},
    'select_village': {'en': 'Select Village', 'lo': 'ເລືອກບ້ານ'},
    'error_saving_address': {
      'en': 'Error saving address',
      'lo': 'ບໍ່ສາມາດບັນທຶກທີ່ຢູ່ໄດ້',
    },
    'choose_shipping': {'en': 'Choose Shipping', 'lo': 'ເລືອກການຂົນສົ່ງ'},
    'shipping_branch': {'en': 'Shipping Branch', 'lo': 'ສາຂາຂົນສົ່ງ'},
    'enter_branch_name': {'en': 'e.g. Branch 1', 'lo': 'ຕົວຢ່າງ: ສາຂາ 1'},
    'branch_required': {
      'en': 'Please enter shipping branch',
      'lo': 'ກະລຸນາປ້ອນສາຂາຂົນສົ່ງ',
    },
    // OTP verification
    'enter_email_or_phone_for_otp': {
      'en': 'Enter your email or phone number to receive an OTP',
      'lo': 'ປ້ອນອີເມວ ຫຼື ເບີໂທຂອງທ່ານເພື່ອຮັບ OTP',
    },
    'email_or_phone': {'en': 'Email or phone number', 'lo': 'ອີເມວ ຫຼື ເບີໂທ'},
    'enter_valid_email_or_phone': {
      'en': 'Please enter a valid email or phone number',
      'lo': 'ກະລຸນາປ້ອນອີເມວ ຫຼື ເບີໂທໃຫ້ຖືກຕ້ອງ',
    },
    'new_password': {'en': 'New Password', 'lo': 'ລະຫັດຜ່ານໃໝ່'},
    'confirm_password': {'en': 'Confirm Password', 'lo': 'ຢືນຢັນລະຫັດຜ່ານ'},
    'please_fill_all_fields': {
      'en': 'Please fill in all fields',
      'lo': 'ກະລຸນາປ້ອນຂໍ້ມູນທັງໝົດ',
    },
    'passwords_do_not_match': {
      'en': 'Passwords do not match',
      'lo': 'ລະຫັດຜ່ານບໍ່ກົງກັນ',
    },
    'password_min_6_chars': {
      'en': 'Password must be at least 6 characters',
      'lo': 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວອັກສອນ',
    },
    'resend_code_in_seconds': {
      'en': 'Resend code in {seconds} seconds',
      'lo': 'ສົ່ງລະຫັດໃໝ່ໃນ {seconds} ວິນາທີ',
    },
    'didnt_receive_code_resend': {
      'en': "Didn't receive code? Resend",
      'lo': 'ບໍ່ໄດ້ຮັບລະຫັດ? ສົ່ງໃໝ່',
    },
    'otp_expired': {'en': 'OTP Expired', 'lo': 'OTP ໝົດອາຍຸ'},
    'reset_password': {'en': 'Reset Password', 'lo': 'ຕັ້ງລະຫັດຜ່ານໃໝ່'},
    'verify_otp': {'en': 'Verify OTP', 'lo': 'ຢືນຢັນ OTP'},
    'get_otp': {'en': 'Get OTP', 'lo': 'ຂໍ OTP'},
    // Payment page
    'payment_methods': {'en': 'Payment Methods', 'lo': 'ວິທີການຊຳລະເງິນ'},
    'select_payment_method': {
      'en': 'Select the payment method you want to use',
      'lo': 'ເລືອກວິທີການຊຳລະເງິນທີ່ທ່ານຕ້ອງການ',
    },
    'scan_qr_to_pay': {
      'en': 'Scan QR Code to Pay',
      'lo': 'ສະແກນ QR Code ເພື່ອຈ່າຍ',
    },
    'scan_qr_description': {
      'en': 'Scan this QR code with your banking app',
      'lo': 'ສະແກນ QR code ນີ້ດ້ວຍແອັບທະນາຄານຂອງທ່ານ',
    },
    'qr_image_not_available': {
      'en': 'QR image not available',
      'lo': 'ບໍ່ມີຮູບ QR',
    },
    'qr_image_save_unavailable': {
      'en': 'QR image not available to save.',
      'lo': 'ບໍ່ມີຮູບ QR ໃຫ້ບັນທຶກ.',
    },
    'qr_code_saved_to': {
      'en': 'QR Code saved to: {path}',
      'lo': 'ບັນທຶກ QR Code ໄປທີ່: {path}',
    },
    'download_qr_code': {'en': 'Download QR Code', 'lo': 'ດາວໂຫຼດ QR Code'},
    'storage_permission_required': {
      'en': 'Storage permission is required to download',
      'lo': 'ຕ້ອງການສິດເຂົ້າເຖິງບ່ອນເກັບຂໍ້ມູນເພື່ອດາວໂຫຼດ',
    },
    'failed_to_download': {
      'en': 'Failed to download: {error}',
      'lo': 'ດາວໂຫຼດບໍ່ສຳເລັດ: {error}',
    },
    'upload_payment_proof': {
      'en': 'Upload Payment Proof',
      'lo': 'ອັບໂຫຼດຫຼັກຖານການຊຳລະ',
    },
    'upload_proof_description': {
      'en': 'Please upload a screenshot or photo of your payment confirmation',
      'lo': 'ກະລຸນາອັບໂຫຼດຮູບພາບ ຫຼື ຫຼັກຖານຂອງການຊຳລະ',
    },
    'camera': {'en': 'Camera', 'lo': 'ກ້ອງຖ່າຍຮູບ'},
    'gallery': {'en': 'Gallery', 'lo': 'ຄັງຮູບ'},
    'payment_proof_uploaded': {
      'en': 'Payment proof uploaded ✓',
      'lo': 'ອັບໂຫຼດຫຼັກຖານສຳເລັດ ✓',
    },
    'upload_payment_proof_required': {
      'en': 'Upload payment proof (Required)',
      'lo': 'ອັບໂຫຼດຫຼັກຖານການຊຳລະ (ຈຳເປັນ)',
    },
    'change_image': {'en': 'Change Image', 'lo': 'ປ່ຽນຮູບ'},
    'upload_image': {'en': 'Upload Image', 'lo': 'ອັບໂຫຼດຮູບ'},
    'please_upload_proof_first': {
      'en': 'Please upload payment proof before confirming!',
      'lo': 'ກະລຸນາອັບໂຫຼດຫຼັກຖານການຊຳລະກ່ອນຢືນຢັນ!',
    },
    'failed_to_upload_slip': {
      'en': 'Failed to upload slip: {error}',
      'lo': 'ອັບໂຫຼດຫຼັກຖານບໍ່ສຳເລັດ: {error}',
    },
    'order_success_title': {'en': 'Order Success', 'lo': 'ສັ່ງຊື້ສຳເລັດ'},
    'order_success_message': {
      'en': 'Your order has been placed successfully!',
      'lo': 'ຄຳສັ່ງຊື້ຂອງທ່ານໄດ້ຖືກສ້າງສຳເລັດແລ້ວ!',
    },
    'order_failed': {'en': 'Order failed', 'lo': 'ສັ່ງຊື້ບໍ່ສຳເລັດ'},
    'confirm_payment': {'en': 'Confirm Payment', 'lo': 'ຢືນຢັນການຊຳລະ'},
    'upload_proof_to_continue': {
      'en': 'Upload Proof to Continue',
      'lo': 'ອັບໂຫຼດຫຼັກຖານເພື່ອສືບຕໍ່',
    },

    // Product/Plant
    'search_plants': {'en': 'Search plants...', 'lo': 'ຄົ້ນຫາພືດ...'},
    'no_plants_found': {'en': 'No plants found', 'lo': 'ບໍ່ພົບພືດ'},
    'add_to_cart': {'en': 'Add to Cart', 'lo': 'ເພີ່ມໃນກະຕ່າ'},
    'out_of_stock': {'en': 'Out of Stock', 'lo': 'ໝົດສາງ'},
    'in_stock': {'en': 'In Stock', 'lo': 'ມີສາງ'},
    'product_details': {'en': 'Product Details', 'lo': 'ລາຍລະອຽດສິນຄ້າ'},
    'description': {'en': 'Description', 'lo': 'ລາຍລະອຽດ'},
    'price': {'en': 'Price', 'lo': 'ລາຄາ'},
    'category': {'en': 'Category', 'lo': 'ໝວດໝູ່'},
    'brand': {'en': 'Brand', 'lo': 'ຍີ່ຫໍ້'},
    'size': {'en': 'Size', 'lo': 'ຂະໜາດ'},
    'color': {'en': 'Color', 'lo': 'ສີ'},
    'quantity': {'en': 'Quantity', 'lo': 'ຈຳນວນ'},

    // Profile & User
    'guest': {'en': 'Guest', 'lo': 'ແຂກ'},
    'failed_to_load_profile': {
      'en': 'Failed to load profile',
      'lo': 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໂປຣໄຟລ໌',
    },
    'male': {'en': 'Male', 'lo': 'ຊາຍ'},
    'female': {'en': 'Female', 'lo': 'ຍິງ'},
    'other': {'en': 'Other', 'lo': 'ອື່ນໆ'},
    'payment': {'en': 'Payment', 'lo': 'ການຈ່າຍເງິນ'},
    'shipping': {'en': 'Shipping', 'lo': 'ການຈັດສົ່ງ'},

    // Actions & Messages
    'search': {'en': 'Search', 'lo': 'ຄົ້ນຫາ'},
    'filter': {'en': 'Filter', 'lo': 'ຕອງ'},
    'sort': {'en': 'Sort', 'lo': 'ຈັດລຽງ'},
    'clear': {'en': 'Clear', 'lo': 'ລຶບລ້າງ'},
    'apply': {'en': 'Apply', 'lo': 'ນຳໃຊ້'},
    'reset': {'en': 'Reset', 'lo': 'ຕັ້ງຄ່າໃໝ່'},
    'refresh': {'en': 'Refresh', 'lo': 'ໂຫຼດໃໝ່'},
    'retry': {'en': 'Retry', 'lo': 'ລອງອີກຄັ້ງ'},
    'okay': {'en': 'Okay', 'lo': 'ຕົກລົງ'},
    'yes': {'en': 'Yes', 'lo': 'ແມ່ນ'},
    'no': {'en': 'No', 'lo': 'ບໍ່'},
    'continue': {'en': 'Continue', 'lo': 'ສືບຕໍ່'},
    'close': {'en': 'Close', 'lo': 'ປິດ'},
    'view_details': {'en': 'View Details', 'lo': 'ເບິ່ງລາຍລະອຽດ'},
    'select': {'en': 'Select', 'lo': 'ເລືອກ'},
    'update': {'en': 'Update', 'lo': 'ອັບເດດ'},
    'upload': {'en': 'Upload', 'lo': 'ອັບໂຫຼດ'},
    'download': {'en': 'Download', 'lo': 'ດາວໂຫຼດ'},

    // Status Messages
    'please_wait': {'en': 'Please wait...', 'lo': 'ກະລຸນາລໍຖ້າ...'},
    'processing': {'en': 'Processing...', 'lo': 'ກຳລັງດຳເນີນການ...'},
    'completed': {'en': 'Completed', 'lo': 'ສຳເລັດແລ້ວ'},
    'failed': {'en': 'Failed', 'lo': 'ບໍ່ສຳເລັດ'},
    'cancelled': {'en': 'Cancelled', 'lo': 'ຍົກເລີກແລ້ວ'},
    'pending': {'en': 'Pending', 'lo': 'ລໍຖ້າ'},
    'confirmed': {'en': 'Confirmed', 'lo': 'ຢືນຢັນແລ້ວ'},
    'shipped': {'en': 'Shipped', 'lo': 'ຈັດສົ່ງແລ້ວ'},
    'delivered': {'en': 'Delivered', 'lo': 'ສົ່ງຮອດແລ້ວ'},

    // Messages
    'please_enter': {'en': 'Please enter', 'lo': 'ກະລຸນາໃສ່ຂໍ້ມູນ'},
    'required_field': {'en': 'This field is required', 'lo': 'ກະລຸນາໃສ່ຂໍ້ມູນ'},

    // Additional Authentication
    'create_your_account': {
      'en': 'Create Your Account',
      'lo': 'ສ້າງບັນຊີຂອງທ່ານ',
    },
    'forget_the_password': {
      'en': 'Forget the password?',
      'lo': 'ລືມລະຫັດຜ່ານບໍ?',
    },
    'sign_in_with_google': {
      'en': 'Sign in with Google',
      'lo': 'ເຂົ້າສູ່ລະບົບດ້ວຍ Google',
    },
    'user_registered_successfully': {
      'en': 'User registered successfully',
      'lo': 'ລົງທະບຽນຜູ້ໃຊ້ສຳເລັດ',
    },
    'congratulations': {'en': 'Congratulations!', 'lo': 'ຂໍສະແດງຄວາມຍິນດີ!'},
    'account_ready_message': {
      'en':
          'Your account is ready to use. You will be redirected to the home page in a few seconds.',
      'lo':
          'ບັນຊີຂອງທ່ານພ້ອມໃຊ້ງານແລ້ວ. ທ່ານຈະຖືກໂອນໄປໜ້າຫຼັກໃນອີກສອງສາມວິນາທີ.',
    },
    'user_request_otp_successfully': {
      'en': 'User request OTP successfully',
      'lo': 'ສົ່ງລະຫັດ OTP ສຳເລັດ',
    },
    'or': {'en': 'or', 'lo': 'ຫຼື'},
    'phone_placeholder': {'en': '20 777 777', 'lo': '20 777 777'},

    // Greetings & Time-based
    'good_morning': {'en': 'Good Morning 👋', 'lo': 'ສະບາຍດີຕອນເຊົ້າ 👋'},
    'good_afternoon': {'en': 'Good Afternoon 🌞', 'lo': 'ສະບາຍດີຕອນບ່າຍ 🌞'},
    'good_evening': {'en': 'Good Evening 🌆', 'lo': 'ສະບາຍດີຕອນແລງ 🌆'},
    'good_night': {'en': 'Good Night 🌙', 'lo': 'ສະບາຍດີຕອນກາງຄືນ 🌙'},

    // Orders & Reviews
    'my_orders': {'en': 'My Orders', 'lo': 'ອໍເດີຂອງຂ້ອຍ'},
    'active': {'en': 'Active', 'lo': 'ກຳລັງດຳເນີນ'},
    'no_orders_yet': {
      'en': "You don't have an order yet",
      'lo': 'ທ່ານຍັງບໍ່ມີອໍເດີ',
    },
    'no_active_orders': {
      'en': "You don't have any active orders at this time",
      'lo': 'ຕອນນີ້ຍັງບໍ່ມີອໍເດີທີ່ກຳລັງດຳເນີນ',
    },
    'no_completed_orders': {
      'en': "You haven't completed any orders yet",
      'lo': 'ທ່ານຍັງບໍ່ມີອໍເດີທີ່ສຳເລັດ',
    },
    'failed_to_load_orders': {
      'en': 'Failed to load orders',
      'lo': 'ບໍ່ສາມາດໂຫຼດອໍເດີໄດ້',
    },
    'please_try_again': {'en': 'Please try again', 'lo': 'ກະລຸນາລອງໃໝ່'},
    'leave_a_review': {'en': 'Leave a Review', 'lo': 'ໃຫ້ຄະແນນ'},
    'how_is_your_order': {
      'en': 'How is your order?',
      'lo': 'ອໍເດີຂອງທ່ານເປັນແນວໃດ?',
    },
    'please_give_rating_review': {
      'en': 'Please give your rating & also your review...',
      'lo': 'ກະລຸນາໃຫ້ຄະແນນ ແລະ ຄຳເຫັນຂອງທ່ານ...',
    },
    'write_your_review_here': {
      'en': 'Write your review here...',
      'lo': 'ຂຽນຄຳເຫັນຂອງທ່ານທີ່ນີ້...',
    },
    'submit': {'en': 'Submit', 'lo': 'ສົ່ງ'},
    'qty': {'en': 'Qty', 'lo': 'ຈຳນວນ'},
    'ordered_on': {'en': 'Ordered', 'lo': 'ສັ່ງເມື່ອ'},
    'ready_on': {'en': 'Ready', 'lo': 'ພ້ອມຮັບເມື່ອ'},
    'plant_singular': {'en': 'plant', 'lo': 'ພືດ'},
    'plant_plural': {'en': 'plants', 'lo': 'ພືດ'},
    'and_more': {'en': '+ {count} more', 'lo': '+ ອີກ {count} ລາຍການ'},
    'please_select_rating': {
      'en': 'Please select a rating',
      'lo': 'ກະລຸນາເລືອກການໃຫ້ຄະແນນ',
    },
    'failed_to_submit_review': {
      'en': 'Failed to submit review',
      'lo': 'ບໍ່ສາມາດສົ່ງການໃຫ້ຄະແນນ',
    },
    'review_submitted': {
      'en': 'Review submitted successfully',
      'lo': 'ສົ່ງການໃຫ້ຄະແນນສຳເລັດ',
    },
    'order_status': {'en': 'Order Status', 'lo': 'ສະຖານະອໍເດີ'},
    'notifications': {'en': 'Notifications', 'lo': 'ການແຈ້ງເຕືອນ'},
    'notif_empty': {
      'en': 'No notifications yet',
      'lo': 'ຍັງບໍ່ມີການແຈ້ງເຕືອນ',
    },
    'mark_all_read': {
      'en': 'Mark all as read',
      'lo': 'ໝາຍວ່າອ່ານທັງໝົດ',
    },
    'notif_today': {'en': 'Today', 'lo': 'ມື້ນີ້'},
    'notif_yesterday': {'en': 'Yesterday', 'lo': 'ມື້ວານ'},
    'notif_placed_title': {'en': 'Order placed', 'lo': 'ສັ່ງອໍເດີແລ້ວ'},
    'notif_placed_sub': {
      'en': 'Waiting for the shop to confirm your order',
      'lo': 'ກຳລັງລໍຖ້າຮ້ານຢືນຢັນອໍເດີຂອງທ່ານ',
    },
    'notif_confirmed_title': {
      'en': 'Order confirmed',
      'lo': 'ຮ້ານຢືນຢັນອໍເດີ',
    },
    'notif_confirmed_sub': {
      'en': 'The shop confirmed your order',
      'lo': 'ຮ້ານໄດ້ຢືນຢັນອໍເດີຂອງທ່ານແລ້ວ',
    },
    'notif_shipping_title': {
      'en': 'Order on the way',
      'lo': 'ອໍເດີກຳລັງສົ່ງ',
    },
    'notif_shipping_sub': {
      'en': 'The shop is delivering your plants',
      'lo': 'ຮ້ານກຳລັງຈັດສົ່ງພືດຂອງທ່ານ',
    },
    'notif_completed_title': {
      'en': 'Order completed',
      'lo': 'ອໍເດີສຳເລັດ',
    },
    'notif_completed_sub': {
      'en': 'You confirmed receiving your plants',
      'lo': 'ທ່ານໄດ້ຢືນຢັນຮັບພືດແລ້ວ',
    },
    'notif_cancelled_title': {
      'en': 'Order cancelled',
      'lo': 'ອໍເດີຖືກຍົກເລີກ',
    },
    'notif_cancelled_sub': {
      'en': 'This order was cancelled',
      'lo': 'ອໍເດີນີ້ຖືກຍົກເລີກ',
    },
    'track_order': {'en': 'Track Order', 'lo': 'ຕິດຕາມອໍເດີ'},
    'track_step_placed': {'en': 'Order\nPlaced', 'lo': 'ສັ່ງ\nແລ້ວ'},
    'track_step_confirmed': {'en': 'Shop\nConfirmed', 'lo': 'ຮ້ານ\nຢືນຢັນ'},
    'track_step_shipping': {'en': 'On the\nWay', 'lo': 'ກຳລັງ\nສົ່ງ'},
    'track_step_completed': {'en': 'Received', 'lo': 'ຮັບແລ້ວ'},
    'stage_pending_msg': {
      'en': 'Waiting for the shop to confirm your order',
      'lo': 'ກຳລັງລໍຖ້າຮ້ານຢືນຢັນອໍເດີຂອງທ່ານ',
    },
    'stage_confirmed_msg': {
      'en': 'Shop confirmed. Preparing your plant',
      'lo': 'ຮ້ານໄດ້ຢືນຢັນ ກຳລັງກະກຽມພືດ',
    },
    'stage_shipping_msg': {
      'en': 'Your plant is on the way',
      'lo': 'ພືດຂອງທ່ານກຳລັງຖືກສົ່ງ',
    },
    'stage_completed_msg': {
      'en': 'Order completed. Enjoy your plant!',
      'lo': 'ອໍເດີສຳເລັດ ມ່ວນກັບພືດຂອງທ່ານ',
    },
    'stage_cancelled_msg': {
      'en': 'This order was cancelled',
      'lo': 'ອໍເດີຖືກຍົກເລີກ',
    },
    'confirm_received': {'en': 'Confirm Received', 'lo': 'ຢືນຢັນຮັບແລ້ວ'},
    'confirm_received_done': {
      'en': 'Order marked as received',
      'lo': 'ໝາຍວ່າໄດ້ຮັບແລ້ວ',
    },
    'tracking_number': {'en': 'Tracking number', 'lo': 'ເລກຕິດຕາມ'},
    'delivery_service': {'en': 'Delivery service', 'lo': 'ບໍລິການຂົນສົ່ງ'},
    'branch': {'en': 'Branch', 'lo': 'ສາຂາ'},
    'order_details': {'en': 'Order Details', 'lo': 'ລາຍລະອຽດອໍເດີ'},
    'order_number': {'en': 'Order Number', 'lo': 'ເລກທີອໍເດີ'},
    'order_date': {'en': 'Order Date', 'lo': 'ວັນທີສັ່ງ'},
    'delivery_date': {'en': 'Delivery Date', 'lo': 'ວັນທີສົ່ງ'},
    'total_amount': {'en': 'Total Amount', 'lo': 'ຍອດລວມ'},

    // Additional keys used in PlantDetail page
    'total_price': {'en': 'Total price', 'lo': 'ລາຄາລວມ'},
    'sold': {'en': 'Sold', 'lo': 'ຂາຍໄໝ້'},
    'reviews': {'en': 'reviews', 'lo': 'ການຖືກປະເມີນ'},
    'plant_not_found': {'en': 'Plant not found', 'lo': 'ບໍ່ພົບພືດ'},
    // Plant Search
    'search_for_plants': {'en': 'Search for plants', 'lo': 'ຄົ້ນຫາພືດ'},
    'enter_keyword_to_find_plants': {
      'en': 'Enter a keyword to find plants',
      'lo': 'ປ້ອນຄີເວີດເພື່ອຄົ້ນຫາພືດ',
    },

    // Payment & Shipping
    'payment_method': {'en': 'Payment Method', 'lo': 'ວິທີການຈ່າຍເງິນ'},
    'shipping_address': {'en': 'Shipping Address', 'lo': 'ທີ່ຢູ່ສົ່ງສິນຄ້າ'},
    'billing_address': {'en': 'Billing Address', 'lo': 'ທີ່ຢູ່ເກັບເງິນ'},
  };

  // Get translation by key and language code
  static String get(String key, String languageCode) {
    return translations[key]?[languageCode] ?? key;
  }
}

// Extension for easy translation access
extension TranslationExtension on String {
  String tr(String languageCode) {
    return AppTranslations.get(this, languageCode);
  }
}
