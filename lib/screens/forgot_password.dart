import 'package:flutter/material.dart';
import '../gen/l10n/app_localizations.dart';
import '../services/api_services.dart';
import '../constants/app_colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 0; // 0: Enter identifier, 1: Enter new password, 2: Success
  String _role = "citizen";
  String _identifier = ""; // Email or username
  String _newPassword = "";
  String _confirmPassword = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final identifierCtrl = TextEditingController();
  final roleCtrl = TextEditingController(text: "citizen");
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  Future<void> _submitIdentifier(AppLocalizations loc) async {
    if (identifierCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.enter_all_fields)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call API to verify user exists
      final success = await ApiService.verifyUserExists(
        identifierCtrl.text.trim(),
        _role,
      );

      if (success) {
        setState(() {
          _identifier = identifierCtrl.text.trim();
          _step = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.user_found)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.user_not_found),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${loc.error}: $e"),
          backgroundColor: AppColors.emergency,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitNewPassword(AppLocalizations loc) async {
    if (newPasswordCtrl.text.isEmpty || confirmPasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.fill_required_fields)),
      );
      return;
    }

    if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.passwords_do_not_match ?? "Passwords do not match"),
          backgroundColor: AppColors.emergency,
        ),
      );
      return;
    }

    if (newPasswordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password must be at least 6 characters"),
          backgroundColor: AppColors.emergency,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ApiService.resetPassword(
        _identifier,
        newPasswordCtrl.text,
        _role,
      );

      if (success) {
        setState(() => _step = 2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.password_reset_successful ?? "Password reset successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.password_reset_failed ?? "Failed to reset password"),
            backgroundColor: AppColors.emergency,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${loc.error}: $e"),
          backgroundColor: AppColors.emergency,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.forgot_password),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _step == 0
            ? _buildIdentifierStep(loc)
            : _step == 1
                ? _buildPasswordStep(loc)
                : _buildSuccessStep(loc),
      ),
    );
  }

  Widget _buildIdentifierStep(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.help_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          loc.account_recovery ?? "Account Recovery",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          loc.enter_email_or_username ?? "Enter your email or username to recover your account",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Role Selection
        DropdownButtonFormField<String>(
          value: _role,
          decoration: InputDecoration(
            labelText: loc.login_as,
            labelStyle: const TextStyle(color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: [
            DropdownMenuItem(value: "citizen", child: Text(loc.citizen)),
            DropdownMenuItem(value: "hospital", child: Text(loc.hospital)),
            DropdownMenuItem(value: "government", child: Text(loc.government)),
          ],
          onChanged: (value) {
            setState(() => _role = value!);
          },
        ),
        const SizedBox(height: 20),

        // Identifier Input
        TextField(
          controller: identifierCtrl,
          decoration: InputDecoration(
            labelText: loc.email_or_username ?? "Email or Username",
            labelStyle: const TextStyle(color: AppColors.primary),
            hintText: "name@example.com or username",
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _submitIdentifier(loc),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(_isLoading ? loc.loading : (loc.verify_account ?? "Verify Account")),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Back to Login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            loc.back_to_login ?? "Back to Login",
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          loc.set_new_password ?? "Set New Password",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          loc.enter_secure_password ?? "Enter a new secure password for your account",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // New Password
        TextField(
          controller: newPasswordCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: loc.new_password ?? "New Password",
            labelStyle: const TextStyle(color: AppColors.primary),
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primary,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Confirm Password
        TextField(
          controller: confirmPasswordCtrl,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: loc.confirm_password ?? "Confirm Password",
            labelStyle: const TextStyle(color: AppColors.primary),
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              child: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primary,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Reset Button
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _submitNewPassword(loc),
          icon: const Icon(Icons.refresh),
          label: Text(_isLoading ? loc.loading : (loc.reset_password ?? "Reset Password")),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          loc.success,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          loc.password_updated_successfully ?? "Your password has been updated successfully",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Back to Login Button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const Icon(Icons.login),
          label: Text(loc.back_to_login ?? "Back to Login"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    identifierCtrl.dispose();
    roleCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }
}
