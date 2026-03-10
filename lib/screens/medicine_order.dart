import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/notification_service.dart';
import '../widgets/profile_menu_button.dart';

class MedicineOrderPage extends StatefulWidget {
  const MedicineOrderPage({super.key});

  @override
  State<MedicineOrderPage> createState() => _MedicineOrderPageState();
}

class _MedicineOrderPageState extends State<MedicineOrderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<MedCareState>();
    _nameController.text = state.recipientName;
    _phoneController.text = state.recipientPhone;
    _addressController.text = state.deliveryAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MedCareState>();
    final selectedStore = state.selectedStore;
    final currentStep = state.currentDeliveryStep;
    final markers = <Marker>[
      if (selectedStore != null)
        Marker(
          point: selectedStore.position,
          width: 120,
          height: 90,
          child: _MapPin(
            icon: Icons.local_pharmacy_rounded,
            color: const Color(0xFF0F766E),
            label: selectedStore.name,
          ),
        ),
      Marker(
        point: state.homePosition,
        width: 110,
        height: 90,
        child: const _MapPin(
          icon: Icons.home_rounded,
          color: Color(0xFFEF4444),
          label: 'Home',
        ),
      ),
      if (state.deliveryProgress.isNotEmpty)
        Marker(
          point: state.deliveryPartnerPosition,
          width: 130,
          height: 90,
          child: const _MapPin(
            icon: Icons.delivery_dining_rounded,
            color: Color(0xFF2563EB),
            label: 'Delivery',
          ),
        ),
    ];

    final polylinePoints = selectedStore == null
        ? <latlng.LatLng>[]
        : <latlng.LatLng>[
            selectedStore.position,
            state.deliveryPartnerPosition,
            state.homePosition,
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Order'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProfileMenuButton(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: state.homePosition,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.medcare',
                  ),
                  PolylineLayer(
                    polylines: polylinePoints.isEmpty
                        ? <Polyline<Object>>[]
                        : [
                            Polyline(
                              points: polylinePoints,
                              color: const Color(0xFF1D6F86),
                              strokeWidth: 5,
                            ),
                          ],
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFDFF7F3),
                    child: Icon(
                      Icons.delivery_dining_rounded,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live delivery map',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedStore == null
                              ? 'Choose a store after payment confirmation to start the map-based delivery flow.'
                              : 'Pickup from ${selectedStore.name} to home in about ${state.etaMinutes} minutes.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Medicine shopping',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          const _CatalogHeader(),
          const SizedBox(height: 14),
          ...state.medicineCatalog.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${item.genericName}\n${item.packLabel}  |  ${item.category}  |  ${item.discountLabel}\n${item.requiresPrescription ? 'Prescription required' : 'OTC available'}',
                  ),
                  trailing: FilledButton(
                    onPressed: () =>
                        context.read<MedCareState>().addToCart(item),
                    child: const Text('Add'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current cart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (state.cart.isEmpty)
                    const Text(
                      'Your cart is empty. Add a medicine to simulate an order.',
                    )
                  else
                    ...state.cart.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} x${item.quantity}',
                              ),
                            ),
                            Text('Rs ${item.total.toStringAsFixed(0)}'),
                            IconButton(
                              onPressed: () => context
                                  .read<MedCareState>()
                                  .updateCartQuantity(
                                    item.product,
                                    item.quantity - 1,
                                  ),
                              icon: const Icon(
                                Icons.remove_circle_outline_rounded,
                              ),
                            ),
                            IconButton(
                              onPressed: () => context
                                  .read<MedCareState>()
                                  .updateCartQuantity(
                                    item.product,
                                    item.quantity + 1,
                                  ),
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                            ),
                            IconButton(
                              onPressed: () => context
                                  .read<MedCareState>()
                                  .removeFromCart(item.product),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Cart total',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        'Rs ${state.cartTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: state.cart.isEmpty
                        ? null
                        : () async {
                            context.read<MedCareState>().confirmPayment();
                            await NotificationService.instance.showNow(
                              id: 550,
                              title: 'Payment confirmed',
                              body:
                                  'Choose a nearby store to continue your medicine order.',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Payment confirmed. Choose a store below.',
                                  ),
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text('Confirm payment'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nearby medical stores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...state.nearbyStores.map(
            (store) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  title: Text(
                    store.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${store.address}\nOwner: ${store.ownerName}  |  ${store.rating.toStringAsFixed(1)} stars  |  ${store.distanceKm.toStringAsFixed(1)} km',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: state.paymentConfirmed
                        ? () => context.read<MedCareState>().selectStore(store)
                        : null,
                    child: Text(
                      selectedStore?.name == store.name ? 'Selected' : 'Choose',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Recipient phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Home address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: state.paymentConfirmed && selectedStore != null
                        ? () async {
                            context.read<MedCareState>().saveDeliveryDetails(
                              name: _nameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                            );
                            await NotificationService.instance.showNow(
                              id: 551,
                              title: 'Order processing started',
                              body:
                                  'The medical store is preparing your medicines.',
                            );
                          }
                        : null,
                    icon: const Icon(Icons.location_on_rounded),
                    label: const Text('Start order processing'),
                  ),
                  if (currentStep != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      currentStep.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(currentStep.detail),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        context.read<MedCareState>().advanceDeliveryDemo();
                        final nextStep = context
                            .read<MedCareState>()
                            .currentDeliveryStep;
                        if (nextStep != null) {
                          await NotificationService.instance.showNow(
                            id: 552,
                            title: nextStep.title,
                            body: nextStep.detail,
                          );
                        }
                      },
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      label: const Text('Advance delivery demo'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Order history',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ...state.orderHistory.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.storeName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            order.id,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.medicinesSummary,
                        style: const TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 6),
                      Text(order.address),
                      const SizedBox(height: 6),
                      Text(
                        '${order.formattedDate}  |  ${order.status}  |  Rs ${order.total.toStringAsFixed(0)}',
                      ),
                    ],
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

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF7F3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop medicines like an online pharmacy',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Browse chronic care medicines, monitoring supplies, nutrition, and devices. Add items to cart, confirm payment, choose your preferred nearby store, and track the delivery to home.',
            style: TextStyle(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.icon, required this.color, required this.label});

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
