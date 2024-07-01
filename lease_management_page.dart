import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:task4/models/lease.dart';
import 'package:task4/pages/renew_lease_page.dart';
import 'package:task4/services/firestore_service.dart';
import 'package:task4/pages/add_lease_page.dart';
import 'package:task4/pages/edit_lease_page.dart';

class LeaseManagementPage extends StatefulWidget {
  const LeaseManagementPage({Key? key}) : super(key: key);

  @override
  _LeaseManagementPageState createState() => _LeaseManagementPageState();
}

class _LeaseManagementPageState extends State<LeaseManagementPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String? selectedBusinessSector;
  String? selectedAgreementType;

  List<String> businessSectors = ['Retail', 'Office', 'Industrial'];
  List<String> agreementTypes = ['Continuing Agreement', 'Annual Agreement'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lease Management'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'Create New Lease':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddLeasePage(),
                    ),
                  ).then((_) => setState(() {}));
                  break;
                case 'Batch Renew Leases':
                  // Implement batch renew leases functionality
                  break;
                case 'Bulk Generate Lease Documents':
                  // Implement bulk generate lease documents functionality
                  break;
                case 'Bulk Actions':
                  // Implement bulk actions functionality
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'Create New Lease',
                  child: Text('Create New Lease'),
                ),
                const PopupMenuItem(
                  value: 'Batch Renew Leases',
                  child: Text('Batch Renew Leases'),
                ),
                const PopupMenuItem(
                  value: 'Bulk Generate Lease Documents',
                  child: Text('Bulk Generate Lease Documents'),
                ),
                const PopupMenuItem(
                  value: 'Bulk Actions',
                  child: Text('Bulk Actions'),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Business Sector'),
                DropdownButton<String>(
                  value: selectedBusinessSector,
                  hint: const Text('Select Business Sector'),
                  onChanged: (value) {
                    setState(() {
                      selectedBusinessSector = value;
                    });
                  },
                  items: businessSectors.map((String sector) {
                    return DropdownMenuItem<String>(
                      value: sector,
                      child: Text(sector),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                const Text('Agreement Type'),
                DropdownButton<String>(
                  value: selectedAgreementType,
                  hint: const Text('Select Agreement Type'),
                  onChanged: (value) {
                    setState(() {
                      selectedAgreementType = value;
                    });
                  },
                  items: agreementTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 112, 144, 170), // Same color as Add and Renew Lease pages
                    onPrimary: Colors.white, // Text color
                  ),
                  child: const Text('Apply Filters'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedBusinessSector = null;
                      selectedAgreementType = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 112, 144, 170), // Same color as Add and Renew Lease pages
                    onPrimary: Colors.white, // Text color
                  ),
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Lease>>(
                    stream: _firestoreService.getLeases(
                      searchTerm: _searchController.text,
                      Business_sector: selectedBusinessSector,
                      Agreement_type: selectedAgreementType,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No leases available'));
                      }

                      final leases = snapshot.data!;

                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 10.0,
                            columns: const [
                              DataColumn(label: Text('Working Area ID')),
                              DataColumn(label: Text('Rented Space Size')),
                              DataColumn(label: Text('Start Date')),
                              DataColumn(label: Text('End Date')),
                              DataColumn(label: Text('Monthly Rent')),
                              DataColumn(label: Text('Agreement Type')),
                              DataColumn(label: Text('Business Sector')),
                              DataColumn(label: Text('Renewal Date')),
                              DataColumn(label: Text('Renewal Term')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: leases.map((lease) {
                              // Calculate remaining days
                              int remainingDays = lease.endDate.difference(DateTime.now()).inDays;

                              // Determine lease status based on remaining days
                              String leaseStatus;
                              if (remainingDays <= 0) {
                                leaseStatus = 'Terminated';
                              } else if (remainingDays <= 15) {
                                leaseStatus = 'Expiring Soon';
                              } else {
                                leaseStatus = 'Active';
                              }

                              // Determine dot color based on remaining days
                              Color dotColor;
                              if (remainingDays <= 15) {
                                dotColor = Colors.red;
                              } else if (remainingDays <= 30) {
                                dotColor = Colors.yellow;
                              } else {
                                dotColor = Colors.green;
                              }

                              return DataRow(cells: [
                                DataCell(Text(lease.working_area_id)),
                                DataCell(Text(lease.Rented_space_size)),
                                DataCell(Text(DateFormat('yyyy-MM-dd').format(lease.startDate))),
                                DataCell(Text(DateFormat('yyyy-MM-dd').format(lease.endDate))),
                                DataCell(Text('\$${lease.monthlyRent.toStringAsFixed(2)}')),
                                DataCell(Text(lease.Agreement_type)),
                                DataCell(Text(lease.Business_sector)),
                                DataCell(Text(lease.Renewal_date)),
                                DataCell(Text(lease.Renewal_term)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditLeasePage(lease: lease),
                                          ),
                                        ).then((_) => setState(() {}));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        await _firestoreService.deleteLease(lease.id);
                                        setState(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () async {
                                        // Fetch the lease object you want to renew (example: first lease in the list)
                                        if (leases.isNotEmpty) {
                                          Lease leaseToRenew = leases[0]; // Example: Take the first lease, you can change this logic

                                          // Navigate to RenewLeasePage with the lease object
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RenewLeasePage(lease: leaseToRenew),
                                            ),
                                          ).then((_) => setState(() {}));
                                        }
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddLeasePage(),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    style: ElevatedButton.styleFrom(
                      primary:const Color.fromARGB(255, 112, 144, 170), // Same color as Add and Renew Lease pages
                      onPrimary: Colors.white, // Text color
                    ),
                    child: const Text('Add Lease'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
