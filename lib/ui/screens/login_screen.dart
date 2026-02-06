import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import 'main_screen.dart';
import '../components/animate_in.dart';
import '../../viewmodels/auth_view_model.dart';


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              AnimateIn(child: _buildHeader(context)),
              Expanded(
                child: SingleChildScrollView(
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
                            _buildTabs(context),
                            const SizedBox(height: 32),
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
                              delay: const Duration(milliseconds: 400),
                              child: _buildTextField(
                                context,
                                'Email Address',
                                viewModel.emailController,
                                Icons.email_outlined,
                              ),
                            ),
                            const SizedBox(height: 24),
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
                            _buildForgotPassword(context),
                            const SizedBox(height: 32),
                            AnimateIn(
                              delay: const Duration(milliseconds: 600),
                              child: _buildLoginButton(context, viewModel),
                            ),
                            const SizedBox(height: 24),
                            _buildDivider(context),
                            const SizedBox(height: 24),
                            AnimateIn(
                              delay: const Duration(milliseconds: 700),
                              child: _buildSocialButtons(),
                            ),
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
      child: Column(children: const [
        Text('Welcome Back!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Sign in to continue your fitness journey', style: TextStyle(color: Color(0xFFAFDDE5), fontSize: 16)),
      ]),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0x4CAFDDE5), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        _buildTabItem(context, 'Login', true),
        _buildTabItem(context, 'Sign Up', false, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Signupscreen()))),
      ]),
    );
  }

  Widget _buildTabItem(BuildContext context, String label, bool active, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: active ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]) : null,
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: Color(active ? 0xFF024950 : 0x99024950), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ]);
  }

  Widget _buildForgotPassword(BuildContext context) {
    return const Align(alignment: Alignment.centerRight, child: Text('Forgot Password?', style: TextStyle(color: Color(0xFF0FA4AF), fontSize: 14)));
  }

  Widget _buildLoginButton(BuildContext context, AuthViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        viewModel.login(context, () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
        });
      },
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]), borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.center,
        child: viewModel.isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('or continue with', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))),
      Expanded(child: Container(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1))),
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
}

