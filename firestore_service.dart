import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task4/models/lease.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionLeases = 'leases';

  Future<void> addLease(Lease lease) async {
    try {
      // Generate a document ID if lease.id is empty
      if (lease.id.isEmpty) {
        lease.id = _db.collection(_collectionLeases).doc().id;
      }
      await _db.collection(_collectionLeases).doc(lease.id).set(lease.toMap());
    } catch (e) {
      print('Error adding lease: $e');
      rethrow;
    }
  }

  Future<void> deleteLease(String leaseId) async {
    try {
      await _db.collection(_collectionLeases).doc(leaseId).delete();
    } catch (e) {
      print('Error deleting lease: $e');
      rethrow;
    }
  }

  Future<void> updateLease(Lease lease) async {
    try {
      await _db.collection(_collectionLeases).doc(lease.id).update(lease.toMap());
    } catch (e) {
      print('Error updating lease: $e');
      rethrow;
    }
  }

  Future<void> renewLease(String leaseId) async {
    try {
      await _db.collection(_collectionLeases).doc(leaseId).update({
        'leaseStatus': 'Active', // Example: Update lease status to Active
        // Add any other fields you want to update for lease renewal
      });
    } catch (e) {
      print('Error renewing lease: $e');
      rethrow;
    }
  }

  Stream<List<Lease>> getLeases({
    String? searchTerm,
    String? Business_sector,
    String? Agreement_type,
    String? leaseStatus,
  }) {
    Query collection = _db.collection(_collectionLeases);

    // Apply filters based on parameters
    if (searchTerm != null && searchTerm.isNotEmpty) {
      collection = collection.where('tenantName', isEqualTo: searchTerm);
    }

    if (Business_sector != null && Business_sector.isNotEmpty) {
      collection = collection.where('Business_sector', isEqualTo: Business_sector);
    }

    if (Agreement_type != null && Agreement_type.isNotEmpty) {
      collection = collection.where('Agreement_type', isEqualTo: Agreement_type);
    }

    if (leaseStatus != null && leaseStatus.isNotEmpty) {
      collection = collection.where('leaseStatus', isEqualTo: leaseStatus);
    }

    return collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Lease.fromFirestore(doc)).toList());
  }
}
