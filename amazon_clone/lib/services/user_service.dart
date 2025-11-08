import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/user/data/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      if (currentUserId == null) return null;

      final docSnapshot = await _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return UserModel.fromJson({
          'id': currentUserId,
          ...data,
        });
      }

      // If user document doesn't exist, create one with basic info
      if (_auth.currentUser != null) {
        final user = _auth.currentUser!;
        final newUser = UserModel(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
        );

        await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .set(newUser.toJson());

        return newUser;
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (currentUserId == null) return false;

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(_usersCollection)
            .doc(currentUserId)
            .update(updateData);

        // Update Firebase Auth display name if provided
        if (name != null && _auth.currentUser != null) {
          await _auth.currentUser!.updateDisplayName(name);
        }

        return true;
      }

      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Add a new address
  Future<bool> addAddress(String address) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection(_usersCollection).doc(currentUserId).update({
        'addresses': FieldValue.arrayUnion([address]),
      });

      return true;
    } catch (e) {
      print('Error adding address: $e');
      return false;
    }
  }

  // Remove an address
  Future<bool> removeAddress(String address) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection(_usersCollection).doc(currentUserId).update({
        'addresses': FieldValue.arrayRemove([address]),
      });

      return true;
    } catch (e) {
      print('Error removing address: $e');
      return false;
    }
  }

  // Add a payment method (in a real app, this would be more secure)
  Future<bool> addPaymentMethod(String paymentMethod) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection(_usersCollection).doc(currentUserId).update({
        'paymentMethods': FieldValue.arrayUnion([paymentMethod]),
      });

      return true;
    } catch (e) {
      print('Error adding payment method: $e');
      return false;
    }
  }

  // Remove a payment method
  Future<bool> removePaymentMethod(String paymentMethod) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection(_usersCollection).doc(currentUserId).update({
        'paymentMethods': FieldValue.arrayRemove([paymentMethod]),
      });

      return true;
    } catch (e) {
      print('Error removing payment method: $e');
      return false;
    }
  }

  // Update Prime membership status
  Future<bool> updatePrimeStatus(bool isPrime) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection(_usersCollection).doc(currentUserId).update({
        'isPrime': isPrime,
      });

      return true;
    } catch (e) {
      print('Error updating Prime status: $e');
      return false;
    }
  }

  // Get mock user data for development
  UserModel getMockUserData() {
    return UserModel(
      id: 'mock-user-id',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      addresses: [
        '123 Main St, Apt 4B, New York, NY 10001',
        '456 Park Ave, Suite 201, San Francisco, CA 94107',
      ],
      paymentMethods: [
        'Visa ending in 4242',
        'Mastercard ending in 5555',
      ],
      isPrime: true,
    );
  }
}