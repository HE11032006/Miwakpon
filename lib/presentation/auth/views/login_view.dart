import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';

// Écran Figma correspondant : "Authentication"
//
// Ce fichier doit contenir le formulaire de connexion/inscription
// utilisant Supabase Auth (email + password).
//
// Le design doit suivre les maquettes Figma "Atelier Benin" :
// - Input fields avec border-bottom style charcoal
// - Bouton principal en Ocre avec inner-glow
// - Typographie Newsreader pour le titre, Be Vietnam Pro pour les champs

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(
            0xFFFAF7F2,
          ), // Fond crème uniforme (plus propre qu'un dégradé trop marqué)
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ), // Empêche l'étirement sur Chrome/Edge
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Consumer<AuthViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Branding épuré
                      const Icon(
                        Icons.palette_outlined,
                        color: Color(0xFF8D5B23),
                        size: 38,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Alatinsa',
                        style: TextStyle(
                          fontFamily: 'Newsreader',
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8D5B23),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.isLoginMode
                            ? 'Enter your artisan workspace'
                            : 'Create your artisan account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 50),

                      if (viewModel.showSuccessMessage)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Account created! Check your mailbox before logging in.",
                            style: TextStyle(color: Colors.green, fontSize: 13),
                          ),
                        ),

                      // Formulaire
                      _buildField(
                        'Email Address',
                        viewModel.emailController,
                        'artisan@alatinsa.com',
                      ),
                      const SizedBox(height: 30),
                      _buildField(
                        'Password',
                        viewModel.passwordController,
                        '••••••••',
                        isPassword: true,
                      ),

                      if (!viewModel.isLoginMode) ...[
                        const SizedBox(height: 30),
                        _buildField(
                          'Confirm Password',
                          viewModel.confirmPasswordController,
                          '••••••••',
                          isPassword: true,
                        ),
                      ],

                      if (viewModel.isLoginMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => viewModel.resetPassword(context),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF8D5B23),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 50),

                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      // Bouton principal (Rectangle simple, sans arrondi excessif)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => viewModel.submitForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D5B23),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  viewModel.isLoginMode
                                      ? 'Sign In →'
                                      : 'Create Account →',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Mode Toggle
                      GestureDetector(
                        onTap: viewModel.toggleMode,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: viewModel.isLoginMode
                                    ? "New to Alatinsa? "
                                    : "Already have an account? ",
                              ),
                              TextSpan(
                                text: viewModel.isLoginMode
                                    ? "Create Account"
                                    : "Sign In",
                                style: const TextStyle(
                                  color: Color(0xFF8D5B23),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label
              .toUpperCase(), // Les labels en majuscules donnent un aspect plus pro/minimal
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.black54,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword,
          cursorColor: const Color(0xFF8D5B23),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[300],
              fontWeight: FontWeight.w300,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8D5B23)),
            ),
          ),
        ),
      ],
    );
  }
}
