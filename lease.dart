import 'package:cloud_firestore/cloud_firestore.dart';

class Lease {
  String id;
  String working_area_id;
  String Rented_space_size;
  DateTime startDate;
  DateTime endDate;
  double monthlyRent;
  String Agreement_type;
  String Business_sector;
  String Renewal_date;
  String Renewal_term;

  Lease({
    required this.id,
    required this.working_area_id,
    required this.Rented_space_size,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.Agreement_type,
    required this.Business_sector,
    required this.Renewal_date,
    required this.Renewal_term,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'working_area_id': working_area_id,
      'Rented_space_size': Rented_space_size,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'monthlyRent': monthlyRent,
      'Agreement_type': Agreement_type,
      'Business_sector': Business_sector,
      'Renewal_date': Renewal_date,
      'Renewal_term': Renewal_term,
    };
  }

  factory Lease.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Lease(
      id: data['id'] ?? '',
      working_area_id: data['working_area_id'] ?? '',
      Rented_space_size: data['Rented_space_size'] ?? '',
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      monthlyRent: data['monthlyRent'] ?? 0.0,
      Agreement_type: data['Agreement_type'] ?? '',
      Business_sector: data['Business_sector'] ?? '',
      Renewal_date: data['Renewal_date'] ?? '',
      Renewal_term: data['Renewal_term'] ?? '',
    );
  }
}
