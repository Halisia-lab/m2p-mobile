import 'package:flutter/material.dart';
import 'package:m2p/exceptions/account_disabled.exception.dart';
import 'package:m2p/exceptions/wrong_credentials.exception.dart';
import 'package:m2p/screens/password_reset.dart';

import '../common/storage.utils.dart';
import '../common/user_interface_dialog.utils.dart';
import '../components/auth_text_field.dart';
import '../exceptions/email_unverified.exception.dart';
import '../exceptions/unauthorized.exception.dart';
import '../screens/home.dart';
import '../services/auth.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  static const String routeName = '/login';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    "Connexion",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10.0),
                  AuthTextField(
                    controller: _emailController,
                    fieldName: "Email",
                    passwordField: false,
                    emailField: true,
                    lastField: false,
                  ),
                  const SizedBox(height: 10.0),
                  AuthTextField(
                    controller: _passwordController,
                    fieldName: "Mot de passe",
                    passwordField: true,
                    confirmPasswordField: false,
                    emailField: false,
                    lastField: true,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => PasswordReset.navigateTo(context),
                        child: Text(
                          "Mot de passe oublié ?",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: Theme.of(context).filledButtonTheme.style,
                        onPressed: onClickLoginButton,
                        child: Text(
                          "connexion".toUpperCase(),
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

  void onClickLoginButton() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        Map<String, dynamic> response = await AuthService.login(
            _emailController.text.trim(), _passwordController.text.trim());
        await StorageUtils.saveUserAuthToken(response["token"]);
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message: "Connexion réussie",
          messageType: MessageType.success,
        );
        Navigator.of(context).pushReplacementNamed(Home.routeName);
      } catch (err) {
        if (err is WrongCredentialsException) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: "L'email ou le mot de passe est incorrect",
            messageType: MessageType.error,
          );
        } else if (err is EmailUnverifiedException) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: "Votre email n'a pas encore été vérifié, allez voir vos emails",
            messageType: MessageType.error,
          );
        } else if (err is AccountDisabledException) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: "Votre compte a été suspendu, contactez le support",
            messageType: MessageType.error,
          );
        } else if (err is UnauthorizedException) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: "Vous n'êtes pas autorisé à effectuer cette action",
            messageType: MessageType.error,
          );
        } else {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message:
                "Échec de l'authentification, tout ne s'est pas passé comme prévu. Réessayer plus tard ou contacter le support",
            messageType: MessageType.error,
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
