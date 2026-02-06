import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';
import '../components/animate_in.dart';
import '../../viewmodels/signup_view_model.dart';


class Signupscreen extends StatelessWidget {
  const Signupscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              AnimateIn(child: _buildHeader(context)),
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
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 25,
                              offset: const Offset(0, 20),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Error message if any
                            if (viewModel.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  viewModel.error!,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ),
                            AnimateIn(
                              delay: const Duration(milliseconds: 300),
                              child: _buildTextField(
                                context,
                                'Full Name',
                                viewModel.nameController,
                                Icons.person_outline,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AnimateIn(
                              delay: const Duration(milliseconds: 400),
                              child: _buildTextField(
                                context,
                                'Email',
                                viewModel.emailController,
                                Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AnimateIn(
                              delay: const Duration(milliseconds: 500),
                              child: _buildTextField(
                                context,
                                'Password',
                                viewModel.passwordController,
                                Icons.lock_outline,
                                isPassword: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AnimateIn(
                              delay: const Duration(milliseconds: 600),
                              child: _buildTextField(
                                context,
                                'Confirm Password',
                                viewModel.confirmPasswordController,
                                Icons.lock_outline,
                                isPassword: true,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTermsAndConditions(context, viewModel),
                            const SizedBox(height: 32),
                            AnimateIn(
                              delay: const Duration(milliseconds: 700),
                              child: _buildSignupButton(context, viewModel),
                            ),
                            const SizedBox(height: 24),
                            _buildDivider(context),
                            const SizedBox(height: 24),
                            AnimateIn(
                              delay: const Duration(milliseconds: 800),
                              child: _buildSocialButtons(),
                            ),
                            const SizedBox(height: 24),
                            _buildLoginLink(context),
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
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
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

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
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

  Widget _buildTermsAndConditions(BuildContext context, SignupViewModel viewModel) {
    return Row(children: [
      Checkbox(
        value: viewModel.agreedToTerms,
        onChanged: (v) => viewModel.setAgreedToTerms(v ?? false),
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      Expanded(
        child: Text(
          'I agree to the Terms & Conditions and Privacy Policy',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
      ),
    ]);
  }

  Widget _buildSignupButton(BuildContext context, SignupViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        viewModel.signup(context, () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileSetupScreen()));
        });
      },
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]), borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.center,
        child: viewModel.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
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

  Widget _buildLoginLink(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Already have an account? '),
      GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
        child: const Text('Login', style: TextStyle(color: Color(0xFF0FA4AF), fontWeight: FontWeight.bold)),
      ),
    ]);
  }
}

