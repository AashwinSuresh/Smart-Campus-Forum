import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/widgets/custom_button.dart';
import 'package:campusapp/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'staff'; // Default to Teacher
  bool _isCreating = false;

  void _createUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMsg("Please fill all fields", isError: true);
      return;
    }

    setState(() => _isCreating = true);
    final success = await ApiService.adminCreateUser(
      email: email,
      password: password,
      fullName: name,
      role: _selectedRole,
    );
    setState(() => _isCreating = false);

    if (success) {
      _showMsg("Successfully created $_selectedRole account!");
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    } else {
      _showMsg("Failed to create user. Check if email exists.", isError: true);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'ADMIN PANEL',
          style: GoogleFonts.oswald(textStyle: const TextStyle(fontSize: 24, letterSpacing: 1.5)),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Generate New Account",
              style: GoogleFonts.robotoFlex(
                textStyle: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            // const Text(
            //   "Only admins can create Staff (Teachers) or Club Rep accounts.",
            //   style: TextStyle(color: Colors.white54),
            // ),
            const SizedBox(height: 40),
            CustomTextField(
              icon: Icons.person_outline,
              label: "Full Name",
              isPassword: false,
              textController: _nameController,
            ),
            CustomTextField(
              icon: Icons.email_outlined,
              label: "Institutional Email",
              isPassword: false,
              textController: _emailController,
            ),
            CustomTextField(
              icon: Icons.lock_outline,
              label: "Set Initial Password",
              isPassword: true,
              textController: _passwordController,
            ),
            const SizedBox(height: 20),
            const Text("SELECT ROLE", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                _roleChip("Staff/Teacher", "staff"),
                const SizedBox(width: 10),
                _roleChip("Club Rep", "club_rep"),
              ],
            ),
            const SizedBox(height: 40),
            CustomButton(
              onPressed: _createUser,
              label: "Create Account",
              isLoading: _isCreating,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String label, String roleValue) {
    bool isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[900],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
