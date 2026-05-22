import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/firebase_constants.dart';

// Provider individual por userId - esto SÍ funciona con family
final userNameProvider = FutureProvider.family<String, String>((ref, userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .get();

    if (!doc.exists) return 'Unknown';
    final data = doc.data()!;
    return data[FirebaseConstants.userNameField] as String? ?? 'Unknown';
  } catch (e) {
    return 'Unknown';
  }
});