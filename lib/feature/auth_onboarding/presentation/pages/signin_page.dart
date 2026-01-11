import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _onGoogleSignIn() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Input background: Very soft grey/white to feel clean
    final inputFillColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
        : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(fontFamily: 'Nunito'),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
          } else if (state is Authenticated) {
            context.go('/story-trails');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. THE HEADER (Organic Curve)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipPath(
                      clipper: _HeaderClipper(),
                      child: Container(
                        height: 200, // Slightly taller for better spacing
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                              theme.colorScheme.primary,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 70,
                      child: Column(
                        children: [
                          // --- FIX 1: VISIBILITY ---
                          // Wrapped in a White Circle to pop against the blue background
                          Container(
                            padding: const EdgeInsets.all(
                              4,
                            ), // White border effect
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/icon/RealIcon2.png',
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 2. THE FORM
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- FIX 3: PHILOSOPHY COPYWRITING ---
                        Text(
                          'Step Back Into the Flow',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your brain remembers the patterns.\nLet\'s wake them up.',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            height: 1.4,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),

                        // Email Field (Soft Pill)
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: _softInputDecoration(
                            theme,
                            'Email',
                            Icons.alternate_email_rounded,
                            inputFillColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field (Soft Pill)
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Password is required'
                              : null,
                          decoration:
                              _softInputDecoration(
                                theme,
                                'Password',
                                Icons.lock_rounded,
                                inputFillColor,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                              ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.push('/forgot-password'),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- FIX 3: BUTTON COPY ---
                        ElevatedButton(
                          onPressed: isLoading ? null : _onSignIn,
                          style: _primaryButtonStyle(theme),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('Immerse Me Again'),
                        ),
                        const SizedBox(height: 28),

                        _buildSoftDivider(theme),
                        const SizedBox(height: 28),

                        // --- FIX 2: GOOGLE ICON BUTTON ---
                        _buildGoogleButton(theme, isLoading),

                        const SizedBox(height: 32),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Haven't started yet?",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => context.push('/signup'),
                              child: Text(
                                'Begin the Process',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- STYLING HELPERS ---

  InputDecoration _softInputDecoration(
    ThemeData theme,
    String label,
    IconData icon,
    Color fillColor,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'Nunito',
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
      ),
      filled: true,
      fillColor: fillColor,
      prefixIcon: Icon(
        icon,
        color: theme.colorScheme.primary.withValues(alpha: 0.7),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(
          color: theme.colorScheme.error.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle(ThemeData theme) => ElevatedButton.styleFrom(
    backgroundColor: theme.colorScheme.primary,
    foregroundColor: theme.colorScheme.onPrimary,
    padding: const EdgeInsets.symmetric(vertical: 18),
    elevation: 6,
    shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    textStyle: const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  Widget _buildGoogleButton(ThemeData theme, bool isLoading) {
    // A clean "Card" look for the button to avoid background blending issues
    return Container(
      decoration: BoxDecoration(
        color: Colors
            .white, // Always white, even in dark mode, for that Google Feel
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _onGoogleSignIn,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // NOTE: Use a TRANSPARENT PNG of the 'G' logo here.
                // If you use a JPG with a white background, the clipping
                // might look rough.
                Image.asset(
                  'assets/icon/google_g.png', // Ensure this is just the "G"
                  height: 24.0,
                  width: 24.0,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Always dark text on white button
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoftDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'or',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60); // Start lower
    // Gentle S-curve or simple arc
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
