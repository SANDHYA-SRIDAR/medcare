class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  Future<void> syncVitals(Map<String, dynamic> payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> syncCaregiverStatus(String status) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<List<String>> fetchStressTips() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const [
      'Try a two-minute breathing reset after a stressful task.',
      'Rotate responsibilities with another family member when possible.',
      'Keep emergency numbers written down even if they are saved on the phone.',
    ];
  }
}
