import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:task4/models/lease.dart';
import 'package:task4/services/firestore_service.dart';

class AddLeasePage extends StatefulWidget {
  const AddLeasePage({Key? key}) : super(key: key);

  @override
  _AddLeasePageState createState() => _AddLeasePageState();
}

class _AddLeasePageState extends State<AddLeasePage> {
  final _db = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _workingAreaIdController = TextEditingController();
  final TextEditingController _rentedSpaceSizeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _monthlyRentController = TextEditingController();
  final TextEditingController _renewalDateController = TextEditingController();
  final TextEditingController _renewalTermController = TextEditingController();

  String? _selectedBusinessSector;
  String? _selectedAgreementType;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Lease'),
        backgroundColor: const Color.fromARGB(255, 112, 144, 170),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextFormField(_workingAreaIdController, 'Working Area ID', 'Please enter working area ID'),
              buildTextFormField(_rentedSpaceSizeController, 'Rented Space Size', 'Please enter rented space size'),
              buildDateFormField(_startDateController, 'Start Date', 'Please enter start date'),
              buildDateFormField(_endDateController, 'End Date', 'Please enter end date'),
              buildTextFormField(_monthlyRentController, 'Monthly Rent', 'Please enter monthly rent', keyboardType: TextInputType.number),
              buildDropdownField('Business Sector', _selectedBusinessSector, ['Retail', 'Office', 'Industrial'], (String? newValue) {
                setState(() {
                  _selectedBusinessSector = newValue;
                });
              }),
              buildDropdownField('Agreement Type', _selectedAgreementType, ['Continuing Agreement', 'Annual Agreement'], (String? newValue) {
                setState(() {
                  _selectedAgreementType = newValue;
                });
              }),
              buildDateFormField(_renewalDateController, 'Renewal Date', 'Please enter renewal date'),
              buildTextFormField(_renewalTermController, 'Renewal Term', 'Please enter renewal term'),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveLease();
                  }
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
                  'Save Lease',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField(TextEditingController controller, String labelText, String validationMessage, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color.fromARGB(255, 151, 151, 153)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: labelText, border: InputBorder.none),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return validationMessage;
              }
              return null;
            },
            keyboardType: keyboardType,
          ),
        ),
      ),
    );
  }

  Widget buildDateFormField(TextEditingController controller, String labelText, String validationMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color:const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color:  const Color.fromARGB(255, 151, 151, 153)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: labelText, border: InputBorder.none),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return validationMessage;
              }
              return null;
            },
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField(String labelText, String? selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color:  const Color.fromARGB(255, 151, 151, 153)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: labelText, border: InputBorder.none),
            value: selectedValue,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $labelText';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  void _saveLease() {
    if (_formKey.currentState!.validate()) {
      DateTime startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      DateTime endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
      DateTime renewalDate = DateFormat('yyyy-MM-dd').parse(_renewalDateController.text);

      if (endDate.isBefore(startDate) || renewalDate.isBefore(startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date and renewal date cannot be before the start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Lease newLease = Lease(
        id: '',
        working_area_id: _workingAreaIdController.text,
        Rented_space_size: _rentedSpaceSizeController.text,
        startDate: startDate,
        endDate: endDate,
        monthlyRent: double.parse(_monthlyRentController.text),
        Agreement_type: _selectedAgreementType!,
        Business_sector: _selectedBusinessSector!,
        Renewal_date: _renewalDateController.text,
        Renewal_term: _renewalTermController.text,
      );

      _firestoreService.addLease(newLease).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        print('Error saving lease: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save lease: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }
}
