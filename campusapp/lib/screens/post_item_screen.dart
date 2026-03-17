import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:flutter/material.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});
  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'lost';
  String _category = 'Electronics';
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _contact = TextEditingController();
  final _name = TextEditingController();
  bool _submitting = false;

  final List<String> _categories = [
    'Electronics',
    'Bag',
    'ID Card',
    'Keys',
    'Wallet',
    'Clothing',
    'Books',
    'Other',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ApiService.createItem({
        'title': _title.text,
        'description': _desc.text,
        'type': _type,
        'category': _category,
        'location': _location.text,
        'contact_info': _contact.text,
        'posted_by': _name.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Report Item'),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Item Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'lost', label: Text('I Lost Something')),
                ButtonSegment(value: 'found', label: Text('I Found Something')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 16),
            _field(_title, 'Item Title', 'e.g. Blue Water Bottle'),
            _field(_desc, 'Description', 'Describe the item...', lines: 3),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white),
                ),
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            _field(_location, 'Location', 'Where was it lost/found?'),
            _field(_contact, 'Contact Info', 'Phone or email'),
            _field(_name, 'Your Name', 'Your name'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                //foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Report',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    String hint, {
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: c,
      maxLines: lines,
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,

      decoration: InputDecoration(
        hintStyle: const TextStyle(color: Colors.white24),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
