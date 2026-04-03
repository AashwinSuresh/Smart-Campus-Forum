import 'package:flutter/material.dart';
import 'package:campusapp/services/harassment_service.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  bool _isSubmitting = false;

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the incident date and time')),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final incidentDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final success = await HarassmentService.createReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        incidentDate: incidentDateTime,
        location: _locationController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.pop(context, true); // Pop out when done
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit report. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Confidential Reporting',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide as much detail as possible. Your report is securely processed without any anonymous tracking per the updated privacy terms.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title / Brief Summary',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Incident Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () => _pickDateTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Incident Date & Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null && _selectedTime != null
                        ? '${_selectedDate!.toLocal().toString().split(' ')[0]} at ${_selectedTime!.format(context)}'
                        : 'Select Date & Time',
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Report', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
