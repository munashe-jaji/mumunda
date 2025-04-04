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
        print("User data saved successfully");
      }

      return user;
    } catch (e) {
      print("Error in signUpWithEmailAndPassword: ${e.toString()}");
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
      print("Error in signInWithEmailAndPassword: ${e.toString()}");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print("Error in signOut: ${e.toString()}");
      return;
    }
  }

  Future<void> updateUserInformation(
    String uid, {
    String? name,
    String? phone,
    String? location,
    String? farmName,
    String? farmSize,
    String? farmingType,
    String? contact,
    String? description,
    String? logo,
    bool? isFarmer,
    bool? isExhibitor,
  }) async {
    try {
      Map<String, dynamic> updatedData = {};

      if (name != null) updatedData['name'] = name;
      if (phone != null) updatedData['phone'] = phone;
      if (location != null) updatedData['location'] = location;
      if (isFarmer != null) updatedData['role'] = isFarmer ? 'farmer' : 'user';
      if (isExhibitor != null) {
        updatedData['role'] = isExhibitor ? 'exhibitor' : 'user';
      }

      if (isFarmer == true) {
        if (farmName != null) updatedData['farmName'] = farmName;
        if (farmSize != null) updatedData['farmSize'] = farmSize;
        if (farmingType != null) updatedData['farmingType'] = farmingType;
      } else if (isExhibitor == true) {
        if (contact != null) updatedData['contact'] = contact;
        if (description != null) updatedData['description'] = description;
        if (logo != null) updatedData['logo'] = logo;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updatedData);
      print("User information updated successfully");
    } catch (e) {
      print("Error in updateUserInformation: ${e.toString()}");
    }
  }

  Future<void> addEvent({
    required String contact,
    required String description,
    required String guests,
    required String location,
    required String name,
    required String schedule,
  }) async {
    try {
      Map<String, dynamic> eventData = {
        'contact': contact,
        'description': description,
        'guests': guests,
        'location': location,
        'name': name,
        'schedule': schedule,
      };

      await FirebaseFirestore.instance.collection('events').add(eventData);
      print("Event added successfully");
    } catch (e) {
      print("Error in addEvent: ${e.toString()}");
    }
  }
}
