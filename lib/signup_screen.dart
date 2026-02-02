import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import 'animate_in.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to Terms & Conditions')));
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          AnimateIn(child: _buildHeader()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: AnimateIn(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 25, offset: Offset(0, 20))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildTextField('Full Name', _nameController, Icons.person_outline)),
                        const SizedBox(height: 16),
                        AnimateIn(delay: const Duration(milliseconds: 400), child: _buildTextField('Email', _emailController, Icons.email_outlined)),
                        const SizedBox(height: 16),
                        AnimateIn(delay: const Duration(milliseconds: 500), child: _buildTextField('Password', _passwordController, Icons.lock_outline, isPassword: true)),
                        const SizedBox(height: 16),
                        AnimateIn(delay: const Duration(milliseconds: 600), child: _buildTextField('Confirm Password', _confirmPasswordController, Icons.lock_outline, isPassword: true)),
                        const SizedBox(height: 24),
                        _buildTermsAndConditions(),
                        const SizedBox(height: 32),
                        AnimateIn(delay: const Duration(milliseconds: 700), child: _buildSignupButton()),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        AnimateIn(delay: const Duration(milliseconds: 800), child: _buildSocialButtons()),
                        const SizedBox(height: 24),
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF003135), Color(0xFF024950)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()))),
          const Expanded(child: Text('Create Account', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(width: 48),
        ]),
        const SizedBox(height: 8),
        const Text('Start your fitness journey today', style: TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
      ]),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
    ]);
  }

  Widget _buildTermsAndConditions() {
    return Row(children: [
      Checkbox(value: _agreedToTerms, onChanged: (v) => setState(() => _agreedToTerms = v ?? false), activeColor: Theme.of(context).colorScheme.primary),
      Expanded(child: Text('I agree to the Terms & Conditions and Privacy Policy', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))),
    ]);
  }

  Widget _buildSignupButton() {
    return GestureDetector(
      onTap: _signup,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]), borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.center,
        child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(children: [
      Expanded(child: Container(height: 1, color: const Color(0xFFAFDDE5))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('or continue with', style: TextStyle(color: Color(0xFF024950)))),
      Expanded(child: Container(height: 1, color: const Color(0xFFAFDDE5))),
    ]);
  }

  Widget _buildSocialButtons() {
    return Row(children: [
      Expanded(child: _buildSocialButton('Google', const Color(0xFF4285F4))),
      const SizedBox(width: 16),
      Expanded(child: _buildSocialButton('Apple', Colors.black)),
    ]);
  }

  Widget _buildSocialButton(String label, Color color) {
    return Container(
      height: 52,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLoginLink() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Already have an account? '),
        GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen())), child: const Text('Login', style: TextStyle(color: Color(0xFF0FA4AF), fontWeight: FontWeight.bold))),
    ]);
  }
}