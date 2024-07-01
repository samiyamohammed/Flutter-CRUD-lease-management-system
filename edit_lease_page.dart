import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:task4/models/lease.dart';
import 'package:task4/services/firestore_service.dart';

class EditLeasePage extends StatefulWidget {
  final Lease lease;

  const EditLeasePage({Key? key, required this.lease}) : super(key: key);

  @override
  _EditLeasePageState createState() => _EditLeasePageState();
}
class _EditLeasePageState extends State<EditLeasePage> {
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _workingAreaIdController;
  late TextEditingController _rentedSpaceSizeController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _monthlyRentController;
  late TextEditingController _agreementTypeController;
  late TextEditingController _businessSectorController;
  late TextEditingController _renewalDateController;
  late TextEditingController _renewalTermController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing lease data
    _workingAreaIdController = TextEditingController(text: widget.lease.working_area_id);
    _rentedSpaceSizeController = TextEditingController(text: widget.lease.Rented_space_size);
    _startDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.lease.startDate));
    _endDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.lease.endDate));
    _monthlyRentController = TextEditingController(text: widget.lease.monthlyRent.toString());
    _agreementTypeController = TextEditingController(text: widget.lease.Agreement_type);
    _businessSectorController = TextEditingController(text: widget.lease.Business_sector);
    _renewalDateController = TextEditingController(text: widget.lease.Renewal_date);
    _renewalTermController = TextEditingController(text: widget.lease.Renewal_term);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lease'),
        backgroundColor: const Color.fromARGB(255, 112, 144, 170),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _workingAreaIdController,
                decoration: const InputDecoration(labelText: 'Working Area ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter working area ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rentedSpaceSizeController,
                decoration: const InputDecoration(labelText: 'Rented Space Size'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rented space size';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Start Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter start date';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.lease.startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'End Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter end date';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.lease.endDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
              TextFormField(
                controller: _monthlyRentController,
                decoration: const InputDecoration(labelText: 'Monthly Rent'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly rent';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _agreementTypeController,
                decoration: const InputDecoration(labelText: 'Agreement Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter agreement type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _businessSectorController,
                decoration: const InputDecoration(labelText: 'Business Sector'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business sector';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _renewalDateController,
                decoration: const InputDecoration(labelText: 'Renewal Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter renewal date';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.lease.endDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _renewalDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
              TextFormField(
                controller: _renewalTermController,
                decoration: const InputDecoration(labelText: 'Renewal Term'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter renewal term';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed to update
                    _updateLease();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 112, 144, 170), // Same color as Renew Lease button
                  onPrimary: Colors.white, // Text color
                ),
                child: const Text('Update Lease'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateLease() {
    // Create updated Lease object from user input
    Lease updatedLease = Lease(
      id: widget.lease.id,
      working_area_id: _workingAreaIdController.text,
      Rented_space_size: _rentedSpaceSizeController.text,
      startDate: DateFormat('yyyy-MM-dd').parse(_startDateController.text),
      endDate: DateFormat('yyyy-MM-dd').parse(_endDateController.text),
      monthlyRent: double.parse(_monthlyRentController.text),
      Agreement_type: _agreementTypeController.text,
      Business_sector: _businessSectorController.text,
      Renewal_date: _renewalDateController.text,
      Renewal_term: _renewalTermController.text,
    );

    // Update in Firestore
    _firestoreService.updateLease(updatedLease).then((_) {
      Navigator.pop(context); // Return to previous screen
    }).catchError((error) {
      // Handle error
      print('Error updating lease: $error');
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    _workingAreaIdController.dispose();
    _rentedSpaceSizeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _monthlyRentController.dispose();
    _agreementTypeController.dispose();
    _businessSectorController.dispose();
    _renewalDateController.dispose();
    _renewalTermController.dispose();
    super.dispose();
  }
}
