import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

Future<void> createUserRecord() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  var usersCollection = FirebaseFirestore.instance.collection('users');
  var username = "user_" + Random().nextInt(9999).toString();

  await usersCollection.doc(user.uid).set({
    'id': user.uid,
    'username': username,
    'points': 0,
  });
}


// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   Future<void> updateUserPoints(int points) async {
//     var user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       var usersCollection = _db.collection('users');
//       var docRef = usersCollection.doc(user.uid);
//
//       var doc = await docRef.get();
//       if (!doc.exists) {
//         String randomUsername = 'user_${Random().nextInt(999999).toString().padLeft(6, '0')}';
//         await docRef.set({
//           'id': user.uid,
//           'username': randomUsername,
//           'points': points,
//         });
//       } else {
//         await docRef.update({
//           'points': FieldValue.increment(points),
//         });
//       }
//     }
//   }
//
//   Stream<List<UserRecord>> getUsersSortedByPoints() {
//     return _db.collection('users')
//         .orderBy('points', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => UserRecord.fromFirestore(doc))
//         .toList());
//   }
// }
//
// class UserRecord {
//   final String id;
//   final String username;
//   final int points;
//
//   UserRecord({required this.id, required this.username, required this.points});
//
//   factory UserRecord.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map;
//     return UserRecord(
//       id: data['id'] ?? '',
//       username: data['username'] ?? 'No Name',
//       points: data['points'] ?? 0,
//     );
//   }
// }