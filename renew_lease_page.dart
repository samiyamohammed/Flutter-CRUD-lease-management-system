import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:task4/models/lease.dart'; // Import your lease model
import 'package:task4/services/firestore_service.dart'; // Import your Firestore service

class RenewLeasePage extends StatefulWidget {
  final Lease lease;

  const RenewLeasePage({Key? key, required this.lease}) : super(key: key);

  @override
  _RenewLeasePageState createState() => _RenewLeasePageState();
}

class _RenewLeasePageState extends State<RenewLeasePage> {
  final TextEditingController _renewalDateController = TextEditingController();
  final TextEditingController _renewalTermController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with current lease values if available
    _renewalDateController.text = widget.lease.Renewal_date;
    _renewalTermController.text = widget.lease.Renewal_term;
    _startDateController.text = DateFormat('yyyy-MM-dd').format(widget.lease.startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(widget.lease.endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew Lease'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lease ID: ${widget.lease.id}'),
            const SizedBox(height: 16.0),
            buildDateFormField(_renewalDateController, 'Renewal Date', 'Select Renewal Date'),
            buildTextFormField(_renewalTermController, 'Renewal Term', 'Enter Renewal Term'),
            const SizedBox(height: 16.0),
            buildDateFormField(_startDateController, 'Start Date', 'Select Start Date'),
            buildDateFormField(_endDateController, 'End Date', 'Select End Date'),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _saveRenewal();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 112, 144, 170)),
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
              child: const Text(
                'Renew Lease',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(TextEditingController controller, String labelText, String validationMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDateFormField(TextEditingController controller, String labelText, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                });
              }
            },
          ),
        ),
      ),
    );
  }

  void _saveRenewal() {
    // Validate fields before saving
    if (_renewalDateController.text.isNotEmpty &&
        _renewalTermController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      
      DateTime startDate = DateTime.parse(_startDateController.text);
      DateTime endDate = DateTime.parse(_endDateController.text);
      DateTime renewalDate = DateTime.parse(_renewalDateController.text);
      
      if (endDate.isBefore(startDate) || renewalDate.isBefore(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date and renewal date cannot be before the start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Update lease object with new renewal details
      Lease renewedLease = Lease(
        id: widget.lease.id,
        working_area_id: widget.lease.working_area_id,
        Rented_space_size: widget.lease.Rented_space_size,
        startDate: startDate,
        endDate: endDate,
        monthlyRent: widget.lease.monthlyRent,
        Agreement_type: widget.lease.Agreement_type,
        Business_sector: widget.lease.Business_sector,
        Renewal_date: _renewalDateController.text,
        Renewal_term: _renewalTermController.text,
      );

      // Call Firestore service to update the lease
      _firestoreService.updateLease(renewedLease).then((_) {
        // Navigate back to previous page on successful renewal
        Navigator.pop(context);
      }).catchError((error) {
        // Handle error if lease renewal fails
        print('Error renewing lease: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to renew lease: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      // Show error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
