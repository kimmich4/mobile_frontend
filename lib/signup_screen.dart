import 'package:flutter/material.dart';
import 'login_screen.dart'; // Assuming navigation to Login
import 'profile_setup_screen.dart'; // Assuming navigation to Profile Setup

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }

    // Navigate to profile setup
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.50, 0.00),
                end: Alignment(0.50, 1.00),
                colors: [Color(0xFF003135), Color(0xFF024950)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance the back button
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your fitness journey today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFAFDDE5),
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),
          
          // Form Section
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 10,
                        offset: Offset(0, 8),
                        spreadRadius: -6,
                      ),
                      BoxShadow(
                        color: Color(0x19000000),
                        blurRadius: 25,
                        offset: Offset(0, 20),
                        spreadRadius: -5,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          color: Color(0xFF024950),
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: const TextStyle(
                            color: Color(0x7F003034),
                            fontSize: 16,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFFAFDDE5), width: 1.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFF024950), width: 1.6),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF024950),
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: const TextStyle(
                            color: Color(0x7F003034),
                            fontSize: 16,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFFAFDDE5), width: 1.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFF024950), width: 1.6),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          color: Color(0xFF024950),
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          hintStyle: const TextStyle(
                            color: Color(0x7F003034),
                            fontSize: 16,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.visibility_off_outlined),
                          enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFFAFDDE5), width: 1.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFF024950), width: 1.6),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Confirm Password
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          color: Color(0xFF024950),
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          hintStyle: const TextStyle(
                            color: Color(0x7F003034),
                            fontSize: 16,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.visibility_off_outlined),
                          enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFFAFDDE5), width: 1.6),
                          ),
                          focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(14),
                             borderSide: const BorderSide(color: Color(0xFF024950), width: 1.6),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Terms and Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF024950),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text(
                                  'I agree to the ',
                                  style: TextStyle(
                                    color: Color(0xFF024950),
                                    fontSize: 14,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Terms & Conditions',
                                    style: TextStyle(
                                      color: Color(0xFF0FA4AF),
                                      fontSize: 14,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ' and ',
                                  style: TextStyle(
                                    color: Color(0xFF024950),
                                    fontSize: 14,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      color: Color(0xFF0FA4AF),
                                      fontSize: 14,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign Up Button
                      GestureDetector(
                        onTap: _signup,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.50, 0.00),
                              end: Alignment(0.50, 1.00),
                              colors: [Color(0xFF024950), Color(0xFF0FA4AF)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 6,
                                offset: Offset(0, 4),
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 15,
                                offset: Offset(0, 10),
                                spreadRadius: -3,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: const Color(0xFFAFDDE5))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color: const Color(0xFF024950),
                                fontSize: 14,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: const Color(0xFFAFDDE5))),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Google',
                              child: const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSocialButton(
                              label: 'Apple',
                              child: const Icon(Icons.apple, color: Colors.black, size: 24),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Link to Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Color(0xFF024950),
                              fontSize: 14,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFF0FA4AF),
                                fontSize: 14,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget child,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFAFDDE5),
          width: 1.6,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF024950),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}