import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim_benim/data/models/user_model.dart';

/// Simple Firestore helper service with common operations.
/// Assumes Firebase has already been initialized (e.g. via Firebase.initializeApp()).
class FirestoreService {
  FirestoreService._private();
  static final FirestoreService instance = FirestoreService._private();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get a collection reference
  CollectionReference collection(String path) => _db.collection(path);

  /// Listen to a collection as a stream of QuerySnapshot
  Stream<QuerySnapshot> streamCollection(
    String path, {
    Query? Function(Query)? queryBuilder,
  }) {
    Query? query = _db.collection(path);
    if (queryBuilder != null) query = queryBuilder(query);
    return query?.snapshots() ?? Stream.empty();
  }

  /// Listen to a document
  Stream<DocumentSnapshot> streamDocument(String path) =>
      _db.doc(path).snapshots();

  /// Get document data once
  Future<DocumentSnapshot> getDocument(String path) => _db.doc(path).get();

  /// Set document (overwrites)
  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return _db.doc(path).set(data, SetOptions(merge: merge));
  }

  /// Add document to collection (auto-id)
  Future<DocumentReference> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).add(data);
  }

  /// Update existing document fields
  Future<void> updateDocument(String path, Map<String, dynamic> data) {
    return _db.doc(path).update(data);
  }

  /// Delete a document
  Future<void> deleteDocument(String path) {
    return _db.doc(path).delete();
  }

  Future<UserModel> getUser(String uid) async {
    final doc = await instance.collection("Users").doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null) {
      return UserModel(
        uid: uid,
        email: data['email'] ?? '',
        displayName: data['displayName'],
        phoneNumber: data['phoneNumber'],
        isPremium: data['isPremium'] ?? false,
        premiumExpiryDate: (data['premiumExpiryDate'] as Timestamp?)?.toDate(),
        totalReadings: data['totalReadings'] ?? 0,
        remaningReadings: data['remaningReadings'] ?? 1,
      );
    } else {
      throw Exception('User not found');
    }
  }
}
