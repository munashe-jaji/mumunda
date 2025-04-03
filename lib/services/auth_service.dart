import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
    String location, {
    String? farmName,
    String? farmSize,
    String? farmingType,
    String? contact,
    String? description,
    String? logo,
    bool isFarmer = false,
    bool isExhibitor = false,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Save user info to Firestore
      if (user != null) {
        Map<String, dynamic> userData = {
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'location': location,
          'role': isFarmer
              ? 'farmer'
              : isExhibitor
                  ? 'exhibitor'
                  : 'user',
        };

        if (isFarmer) {
          userData.addAll({
            'farmName': farmName,
            'farmSize': farmSize,
            'farmingType': farmingType,
          });
        } else if (isExhibitor) {
          userData.addAll({
            'contact': contact,
            'description': description,
            'logo': logo,
          });
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
      }

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return;
    }
  }
}
