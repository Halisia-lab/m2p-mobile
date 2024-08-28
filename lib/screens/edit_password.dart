import 'package:flutter/material.dart';

import '../common/user_interface_dialog.utils.dart';
import '../components/auth_text_field.dart';
import '../exceptions/wrong_credentials.exception.dart';
import '../main.dart';
import '../screens/profile.dart';
import '../services/user.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({Key? key}) : super(key: key);

  static const String routeName = '/edit_password';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                children: [
                  Text(
                    "Modifier mon mot de passe",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20.0),
                  AuthTextField(
                    controller: _currentPasswordController,
                    fieldName: "Mot de passe actuel",
                    passwordField: true,
                    confirmPasswordField: false,
                    emailField: false,
                    lastField: false,
                  ),
                  const SizedBox(height: 10.0),
                  AuthTextField(
                    controller: _newPasswordController,
                    fieldName: "Nouveau mot de passe",
                    passwordField: true,
                    confirmPasswordField: false,
                    emailField: false,
                    lastField: false,
                  ),
                  const SizedBox(height: 10.0),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    fieldName: "Confirmation du mot de passe",
                    passwordController: _newPasswordController,
                    passwordField: true,
                    confirmPasswordField: true,
                    emailField: false,
                    lastField: true,
                  ),
                  const SizedBox(height: 20.0),
                  OutlinedButton(
                    style: Theme.of(context).filledButtonTheme.style,
                    onPressed: onPressedModificationButton,
                    child: Text(
                      "Modifier".toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
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

  void onPressedModificationButton() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        var token = await storage.read(key: "token");
        await UserService.updatePassword(
            token!,
            _currentPasswordController.text.trim(),
            _newPasswordController.text.trim());
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message: "Modification réussie",
          messageType: MessageType.success,
        );
        _getUser().then((user) {
          Profile.popNavigateTo(context, user);
        });
      } catch (err) {
        if (err is WrongCredentialsException) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message:
                "Votre mot de passe actuel est incorrect. Veuillez réessayer.",
            messageType: MessageType.error,
          );
        } else {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: err.toString(),
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

  Future _getUser() async {
    try {
      var token = await storage.read(key: "token");
      return await UserService.getUser(token!);
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
          context,
          "Nous n'avons pas pu charger vos données.",
          "Veuillez réessayer plus tard.");
    }
  }
}


// GERE L'ERREUR WRONG CREDENTIALS