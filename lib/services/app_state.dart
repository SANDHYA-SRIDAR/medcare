import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  UserProfile({
    required this.fullName,
    required this.username,
    required this.userId,
    required this.password,
    required this.createdAtIso,
  });

  final String fullName;
  final String username;
  final String userId;
  final String password;
  final String createdAtIso;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return username.substring(0, 1).toUpperCase();
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'userId': userId,
      'password': password,
      'createdAtIso': createdAtIso,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      fullName: map['fullName'] as String,
      username: map['username'] as String,
      userId: map['userId'] as String,
      password: map['password'] as String,
      createdAtIso: map['createdAtIso'] as String,
    );
  }
}

class Medication {
  Medication({
    required this.name,
    required this.dose,
    required this.time,
    this.taken = false,
  });

  final String name;
  final String dose;
  final TimeOfDay time;
  bool taken;

  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class HealthReading {
  HealthReading({
    required this.bloodPressure,
    required this.sugar,
    required this.pulse,
    required this.updatedAt,
    required this.notes,
  });

  final String bloodPressure;
  final double sugar;
  final int pulse;
  final DateTime updatedAt;
  final String notes;

  String get formattedDate => DateFormat('d MMM, h:mm a').format(updatedAt);
}

class CaregiverTaskItem {
  CaregiverTaskItem({
    required this.title,
    required this.subtitle,
    this.done = false,
  });

  final String title;
  final String subtitle;
  bool done;
}

class CommunityPost {
  CommunityPost({
    required this.author,
    required this.message,
    required this.timeLabel,
  });

  final String author;
  final String message;
  final String timeLabel;
}

class ChatMessage {
  ChatMessage({
    required this.author,
    required this.message,
    required this.timeLabel,
    required this.senderRole,
  });

  final String author;
  final String message;
  final String timeLabel;
  final String senderRole;

  bool get fromGuardian => senderRole == 'Guardian';
}

class EmergencyContact {
  EmergencyContact({
    required this.label,
    required this.phone,
    required this.icon,
  });

  String label;
  String phone;
  IconData icon;
}

class MedicineProduct {
  MedicineProduct({
    required this.name,
    required this.genericName,
    required this.packLabel,
    required this.price,
    required this.discountLabel,
    required this.form,
    required this.category,
    required this.requiresPrescription,
  });

  final String name;
  final String genericName;
  final String packLabel;
  final double price;
  final String discountLabel;
  final String form;
  final String category;
  final bool requiresPrescription;
}

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final MedicineProduct product;
  int quantity;

  double get total => product.price * quantity;
}

class MedicalStore {
  MedicalStore({
    required this.name,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
    required this.distanceKm,
    required this.etaMinutes,
    required this.rating,
    required this.position,
  });

  final String name;
  final String address;
  final String ownerName;
  final String ownerPhone;
  final double distanceKm;
  final int etaMinutes;
  final double rating;
  final LatLng position;
}

class DeliveryStop {
  DeliveryStop({
    required this.title,
    required this.subtitle,
    required this.position,
    required this.isHome,
  });

  final String title;
  final String subtitle;
  final LatLng position;
  final bool isHome;
}

class DeliveryProgressStep {
  DeliveryProgressStep({
    required this.title,
    required this.detail,
    required this.etaMinutes,
  });

  final String title;
  final String detail;
  final int etaMinutes;
}

class OrderRecord {
  OrderRecord({
    required this.id,
    required this.storeName,
    required this.medicinesSummary,
    required this.address,
    required this.orderedAt,
    required this.total,
    required this.paymentConfirmed,
    required this.status,
    required this.etaMinutes,
  });

  final String id;
  final String storeName;
  final String medicinesSummary;
  final String address;
  final DateTime orderedAt;
  final double total;
  final bool paymentConfirmed;
  String status;
  int etaMinutes;

  String get formattedDate => DateFormat('d MMM, h:mm a').format(orderedAt);
}

class MedCareState extends ChangeNotifier {
  static const _usersKey = 'medcare_users';
  static const _currentUsernameKey = 'medcare_current_username';

  SharedPreferences? _prefs;
  final List<UserProfile> _registeredUsers = [];
  UserProfile? currentUser;

  List<UserProfile> get registeredUsers => List.unmodifiable(_registeredUsers);
  bool get isLoggedIn => currentUser != null;

  final List<Medication> medications = [
    Medication(
      name: 'Amlodipine',
      dose: '5 mg',
      time: const TimeOfDay(hour: 8, minute: 0),
    ),
    Medication(
      name: 'Metformin',
      dose: '500 mg',
      time: const TimeOfDay(hour: 13, minute: 0),
    ),
    Medication(
      name: 'Calcium + Vitamin D3',
      dose: '1 tablet',
      time: const TimeOfDay(hour: 20, minute: 0),
    ),
  ];

  final List<CaregiverTaskItem> caregiverTasks = [
    CaregiverTaskItem(
      title: 'Morning medicine check',
      subtitle: 'Confirm all breakfast medicines were taken',
      done: true,
    ),
    CaregiverTaskItem(
      title: 'Upload BP reading',
      subtitle: 'Capture and verify afternoon blood pressure',
    ),
    CaregiverTaskItem(
      title: 'Hydration reminder',
      subtitle: 'Mark 6 glasses of water goal',
    ),
    CaregiverTaskItem(
      title: 'Evening walk support',
      subtitle: 'Accompany or verify 15-minute walk',
    ),
  ];

  final List<CommunityPost> supportPosts = [
    CommunityPost(
      author: 'Anita',
      message:
          'Short breathing breaks between tasks have helped me stay calm this week.',
      timeLabel: '10 min ago',
    ),
    CommunityPost(
      author: 'Rahul',
      message:
          'Keep a simple handwritten checklist near the dining table. It reduces missed medicines.',
      timeLabel: '35 min ago',
    ),
  ];

  final List<ChatMessage> messages = [
    ChatMessage(
      author: 'Guardian',
      message: 'Please confirm the sugar reading after lunch.',
      timeLabel: '09:10 AM',
      senderRole: 'Guardian',
    ),
    ChatMessage(
      author: 'Caregiver',
      message: 'Done. I have logged 128 mg/dL and updated the notes.',
      timeLabel: '09:14 AM',
      senderRole: 'Caregiver',
    ),
  ];

  final List<EmergencyContact> emergencyContacts = [
    EmergencyContact(
      label: 'Caregiver',
      phone: '+919900000101',
      icon: Icons.health_and_safety_rounded,
    ),
    EmergencyContact(
      label: 'Guardian',
      phone: '+919900000102',
      icon: Icons.family_restroom_rounded,
    ),
    EmergencyContact(
      label: 'Friend / Neighbor',
      phone: '+919900000103',
      icon: Icons.group_rounded,
    ),
    EmergencyContact(
      label: 'Ambulance',
      phone: '108',
      icon: Icons.emergency_rounded,
    ),
    EmergencyContact(
      label: 'Nearby Hospital',
      phone: '+919900000104',
      icon: Icons.local_hospital_rounded,
    ),
  ];

  final List<MedicineProduct> medicineCatalog = [
    MedicineProduct(
      name: 'Telma 40 Tablet',
      genericName: 'Telmisartan',
      packLabel: 'Strip of 15 tablets',
      price: 182,
      discountLabel: '12% off',
      form: 'Tablet',
      category: 'Blood pressure',
      requiresPrescription: true,
    ),
    MedicineProduct(
      name: 'Glycomet GP 1 Tablet',
      genericName: 'Metformin + Glimepiride',
      packLabel: 'Strip of 10 tablets',
      price: 96,
      discountLabel: '8% off',
      form: 'Tablet',
      category: 'Diabetes',
      requiresPrescription: true,
    ),
    MedicineProduct(
      name: 'Accu-Chek Active Strips',
      genericName: 'Glucose test strips',
      packLabel: 'Box of 50 strips',
      price: 999,
      discountLabel: '5% off',
      form: 'Strip',
      category: 'Sugar monitoring',
      requiresPrescription: false,
    ),
    MedicineProduct(
      name: 'Shelcal 500',
      genericName: 'Calcium + Vitamin D3',
      packLabel: 'Strip of 15 tablets',
      price: 142,
      discountLabel: '10% off',
      form: 'Tablet',
      category: 'Bone health',
      requiresPrescription: false,
    ),
    MedicineProduct(
      name: 'Dolo 650',
      genericName: 'Paracetamol',
      packLabel: 'Strip of 15 tablets',
      price: 34,
      discountLabel: 'MedSaver price',
      form: 'Tablet',
      category: 'Fever and pain',
      requiresPrescription: false,
    ),
    MedicineProduct(
      name: 'Ensure Diabetes Care',
      genericName: 'Nutrition powder',
      packLabel: 'Jar of 400 g',
      price: 745,
      discountLabel: '15% off',
      form: 'Powder',
      category: 'Nutrition',
      requiresPrescription: false,
    ),
    MedicineProduct(
      name: 'Digital BP Monitor Cuff',
      genericName: 'Upper arm cuff',
      packLabel: '1 unit',
      price: 1499,
      discountLabel: 'Combo eligible',
      form: 'Device',
      category: 'Vitals devices',
      requiresPrescription: false,
    ),
  ];

  final List<MedicalStore> nearbyStores = [
    MedicalStore(
      name: 'MedPlus Indiranagar',
      address: '100 Feet Road, Indiranagar, Bengaluru',
      ownerName: 'Rakesh Nair',
      ownerPhone: '+919876540111',
      distanceKm: 0.8,
      etaMinutes: 18,
      rating: 4.7,
      position: const LatLng(12.9719, 77.5945),
    ),
    MedicalStore(
      name: 'Apollo Pharmacy Domlur',
      address: 'Old Airport Road, Domlur, Bengaluru',
      ownerName: 'Suhas Menon',
      ownerPhone: '+919876540112',
      distanceKm: 1.6,
      etaMinutes: 24,
      rating: 4.5,
      position: const LatLng(12.9667, 77.6101),
    ),
    MedicalStore(
      name: 'CarePlus 24x7',
      address: 'HAL 2nd Stage, Bengaluru',
      ownerName: 'Farah Khan',
      ownerPhone: '+919876540113',
      distanceKm: 2.1,
      etaMinutes: 29,
      rating: 4.3,
      position: const LatLng(12.9788, 77.6089),
    ),
  ];

  final List<CartItem> cart = [];
  final List<OrderRecord> orderHistory = [
    OrderRecord(
      id: 'MC-2401',
      storeName: 'Apollo Pharmacy Domlur',
      medicinesSummary: 'Dolo 650, Shelcal 500',
      address: '12 Lake View Road, Indiranagar, Bengaluru',
      orderedAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      total: 176,
      paymentConfirmed: true,
      status: 'Delivered',
      etaMinutes: 0,
    ),
  ];

  final LatLng homePosition = const LatLng(12.9756, 77.6066);

  HealthReading latestReading = HealthReading(
    bloodPressure: '128/82',
    sugar: 124,
    pulse: 72,
    updatedAt: DateTime.now().subtract(const Duration(minutes: 18)),
    notes: 'Stable after breakfast and light walk.',
  );

  String caregiverStatus = 'Checked in, medicines verified, mood calm';
  String caregiverWellbeing = 'Doing okay but needs a short afternoon break.';
  bool vitalsConfirmedByCaregiver = true;

  bool paymentConfirmed = false;
  MedicalStore? selectedStore;
  String recipientName = 'K. Raman';
  String recipientPhone = '+919900000110';
  String deliveryAddress = '12 Lake View Road, Indiranagar, Bengaluru';
  List<DeliveryStop> deliveryStops = [];
  List<DeliveryProgressStep> deliveryProgress = [];
  int deliveryProgressIndex = 0;
  OrderRecord? activeOrder;

  double get cartTotal => cart.fold<double>(0, (sum, item) => sum + item.total);

  int get cartItemCount =>
      cart.fold<int>(0, (sum, item) => sum + item.quantity);

  int get etaMinutes {
    if (activeOrder != null) {
      return activeOrder!.etaMinutes;
    }
    return selectedStore?.etaMinutes ?? 18;
  }

  DeliveryProgressStep? get currentDeliveryStep {
    if (deliveryProgress.isEmpty) {
      return null;
    }
    return deliveryProgress[deliveryProgressIndex];
  }

  LatLng get deliveryPartnerPosition {
    final store = selectedStore;
    if (store == null) {
      return homePosition;
    }
    if (deliveryProgress.isEmpty) {
      return store.position;
    }
    final progressFactor = deliveryProgress.length == 1
        ? 1.0
        : deliveryProgressIndex / (deliveryProgress.length - 1);
    return LatLng(
      store.position.latitude +
          ((homePosition.latitude - store.position.latitude) * progressFactor),
      store.position.longitude +
          ((homePosition.longitude - store.position.longitude) *
              progressFactor),
    );
  }

  Future<void> initializeSession() async {
    _prefs ??= await SharedPreferences.getInstance();
    final rawUsers = _prefs!.getString(_usersKey);
    _registeredUsers
      ..clear()
      ..addAll(
        rawUsers == null
            ? []
            : (jsonDecode(rawUsers) as List<dynamic>).map(
                (entry) => UserProfile.fromMap(entry as Map<String, dynamic>),
              ),
      );

    final currentUsername = _prefs!.getString(_currentUsernameKey);
    if (currentUsername != null) {
      currentUser = _registeredUsers.cast<UserProfile?>().firstWhere(
        (user) => user?.username == currentUsername,
        orElse: () => null,
      );
    }
  }

  Future<String?> registerUser({
    required String fullName,
    required String username,
    required String password,
  }) async {
    await initializeSession();

    final normalizedUsername = username.trim().toLowerCase();
    if (_registeredUsers.any(
      (user) => user.username.toLowerCase() == normalizedUsername,
    )) {
      return 'Username already exists. Choose a different username.';
    }

    final user = UserProfile(
      fullName: fullName.trim(),
      username: username.trim(),
      userId: _generateUserId(),
      password: password,
      createdAtIso: DateTime.now().toIso8601String(),
    );

    _registeredUsers.add(user);
    currentUser = user;
    await _persistUsers();
    notifyListeners();
    return null;
  }

  Future<String?> loginUser({
    required String username,
    required String password,
  }) async {
    await initializeSession();

    final normalizedUsername = username.trim().toLowerCase();
    final user = _registeredUsers.cast<UserProfile?>().firstWhere(
      (entry) => entry?.username.toLowerCase() == normalizedUsername,
      orElse: () => null,
    );

    if (user == null || user.password != password) {
      return 'Invalid username or password.';
    }

    currentUser = user;
    await _persistUsers();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    currentUser = null;
    if (_prefs != null) {
      await _prefs!.remove(_currentUsernameKey);
    }
    notifyListeners();
  }

  Future<void> _persistUsers() async {
    await _prefs?.setString(
      _usersKey,
      jsonEncode(_registeredUsers.map((user) => user.toMap()).toList()),
    );
    if (currentUser != null) {
      await _prefs?.setString(_currentUsernameKey, currentUser!.username);
    }
  }

  String _generateUserId() {
    return 'MDC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
  }

  void toggleMedication(int index) {
    medications[index].taken = !medications[index].taken;
    notifyListeners();
  }

  void updateVitals({
    required String bloodPressure,
    required double sugar,
    required int pulse,
    required String notes,
    required bool confirmedByCaregiver,
  }) {
    latestReading = HealthReading(
      bloodPressure: bloodPressure,
      sugar: sugar,
      pulse: pulse,
      updatedAt: DateTime.now(),
      notes: notes,
    );
    vitalsConfirmedByCaregiver = confirmedByCaregiver;
    notifyListeners();
  }

  void toggleTask(int index) {
    caregiverTasks[index].done = !caregiverTasks[index].done;
    notifyListeners();
  }

  void updateCaregiverStatus(String status) {
    caregiverStatus = status;
    notifyListeners();
  }

  void updateCaregiverWellbeing(String message) {
    caregiverWellbeing = message;
    notifyListeners();
  }

  void addSupportPost(String author, String message) {
    if (message.trim().isEmpty) {
      return;
    }
    supportPosts.insert(
      0,
      CommunityPost(
        author: author,
        message: message.trim(),
        timeLabel: 'Just now',
      ),
    );
    notifyListeners();
  }

  void addChatMessage({
    required String author,
    required String message,
    required String senderRole,
  }) {
    if (message.trim().isEmpty) {
      return;
    }
    messages.add(
      ChatMessage(
        author: author,
        message: message.trim(),
        timeLabel: DateFormat('hh:mm a').format(DateTime.now()),
        senderRole: senderRole,
      ),
    );
    notifyListeners();
  }

  void updateEmergencyContact(
    int index, {
    required String label,
    required String phone,
  }) {
    emergencyContacts[index].label = label;
    emergencyContacts[index].phone = phone;
    notifyListeners();
  }

  void addEmergencyContact({required String label, required String phone}) {
    emergencyContacts.add(
      EmergencyContact(
        label: label,
        phone: phone,
        icon: Icons.contact_phone_rounded,
      ),
    );
    notifyListeners();
  }

  void addToCart(MedicineProduct product) {
    final existingIndex = cart.indexWhere(
      (item) => item.product.name == product.name,
    );
    if (existingIndex >= 0) {
      cart[existingIndex].quantity += 1;
    } else {
      cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void updateCartQuantity(MedicineProduct product, int quantity) {
    final existingIndex = cart.indexWhere(
      (item) => item.product.name == product.name,
    );
    if (existingIndex == -1) {
      return;
    }
    if (quantity <= 0) {
      cart.removeAt(existingIndex);
    } else {
      cart[existingIndex].quantity = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(MedicineProduct product) {
    cart.removeWhere((item) => item.product.name == product.name);
    notifyListeners();
  }

  void confirmPayment() {
    if (cart.isEmpty) {
      return;
    }
    paymentConfirmed = true;
    selectedStore = null;
    deliveryStops = [];
    deliveryProgress = [];
    deliveryProgressIndex = 0;
    activeOrder = null;
    notifyListeners();
  }

  void selectStore(MedicalStore store) {
    selectedStore = store;
    notifyListeners();
  }

  void saveDeliveryDetails({
    required String name,
    required String phone,
    required String address,
  }) {
    if (!paymentConfirmed || selectedStore == null) {
      return;
    }

    recipientName = name;
    recipientPhone = phone;
    deliveryAddress = address;
    deliveryStops = [
      DeliveryStop(
        title: selectedStore!.name,
        subtitle: 'Store confirms medicines and packs order',
        position: selectedStore!.position,
        isHome: false,
      ),
      DeliveryStop(
        title: 'Delivery partner on the way',
        subtitle: 'Picked up from the medical store',
        position: LatLng(
          (selectedStore!.position.latitude + homePosition.latitude) / 2,
          (selectedStore!.position.longitude + homePosition.longitude) / 2,
        ),
        isHome: false,
      ),
      DeliveryStop(
        title: 'Home delivery',
        subtitle: deliveryAddress,
        position: homePosition,
        isHome: true,
      ),
    ];
    deliveryProgress = [
      DeliveryProgressStep(
        title: 'Order being processed',
        detail:
            '${selectedStore!.name} owner ${selectedStore!.ownerName} is verifying the medicines.',
        etaMinutes: selectedStore!.etaMinutes,
      ),
      DeliveryProgressStep(
        title: 'Packed and ready',
        detail:
            'Prescription and availability have been confirmed by the store.',
        etaMinutes: (selectedStore!.etaMinutes - 6).clamp(4, 60),
      ),
      DeliveryProgressStep(
        title: 'Out for delivery',
        detail:
            'Delivery partner has picked up the medicines and is approaching the house.',
        etaMinutes: (selectedStore!.etaMinutes - 12).clamp(2, 60),
      ),
      DeliveryProgressStep(
        title: 'Delivered',
        detail:
            'Medicines reached $deliveryAddress and were handed over successfully.',
        etaMinutes: 0,
      ),
    ];
    deliveryProgressIndex = 0;
    activeOrder = OrderRecord(
      id: 'MC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      storeName: selectedStore!.name,
      medicinesSummary: _cartSummary(),
      address: deliveryAddress,
      orderedAt: DateTime.now(),
      total: cartTotal,
      paymentConfirmed: true,
      status: deliveryProgress.first.title,
      etaMinutes: deliveryProgress.first.etaMinutes,
    );
    orderHistory.insert(0, activeOrder!);
    notifyListeners();
  }

  void advanceDeliveryDemo() {
    if (deliveryProgress.isEmpty || activeOrder == null) {
      return;
    }
    if (deliveryProgressIndex < deliveryProgress.length - 1) {
      deliveryProgressIndex += 1;
      activeOrder!.status = deliveryProgress[deliveryProgressIndex].title;
      activeOrder!.etaMinutes =
          deliveryProgress[deliveryProgressIndex].etaMinutes;
      if (deliveryProgressIndex == deliveryProgress.length - 1) {
        cart.clear();
        paymentConfirmed = false;
      }
      notifyListeners();
    }
  }

  String _cartSummary() {
    return cart
        .map(
          (item) => item.quantity > 1
              ? '${item.product.name} x${item.quantity}'
              : item.product.name,
        )
        .join(', ');
  }
}
