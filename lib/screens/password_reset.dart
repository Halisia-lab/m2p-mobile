import 'package:flutter/material.dart';
import 'package:m2p/exceptions/not_found.exception.dart';
import 'package:m2p/services/auth.dart';

import '../common/user_interface_dialog.utils.dart';
import '../components/auth_text_field.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({super.key});

  static const String routeName = '/password_reset';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Réinitialiser le mot de passe",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20.0),
                  AuthTextField(
                    controller: _emailController,
                    fieldName: "Email",
                    passwordField: false,
                    emailField: true,
                    lastField: false,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: Theme.of(context).filledButtonTheme.style,
                        onPressed: onClickResetPasswortButton,
                        child: Text(
                          "Confirmer".toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Visibility(
                  child: AlertDialog(
                    elevation: 500,
                    backgroundColor: Colors.transparent,
                    content: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  visible: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onClickResetPasswortButton() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await AuthService.resetPassword(_emailController.text.trim());
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message: "Email envoyé à ${_emailController.text.trim()}, veuillez vérifier votre boîte de réception",
          messageType: MessageType.success,
        );
        Navigator.of(context).pop();
      } catch (err) {
        if (err is NotFoundException){
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: "Email envoyé à ${_emailController.text.trim()}, veuillez vérifier votre boîte de réception",
            messageType: MessageType.success,
          );
          Navigator.of(context).pop();
        }
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message:
          "Échec de l'envoie du mail. Réessayer plus tard ou contacter le support",
          messageType: MessageType.error,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
