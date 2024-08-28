import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../common/user_interface_dialog.utils.dart';
import '../components/auth_text_field.dart';
import '../components/date_text_field.dart';
import '../components/profile_image_picker.dart';
import '../models/user_dto.dart';
import 'register_second.dart';

class RegisterFirst extends StatefulWidget {
  const RegisterFirst({Key? key}) : super(key: key);

  @override
  State<RegisterFirst> createState() => _RegisterFirstState();

  static const String routeName = '/register-first';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }
}

class _RegisterFirstState extends State<RegisterFirst> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
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
                    "Inscription",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: ProfileImagePicker(
                        pickImage: _pickImage, imageFile: _imageFile),
                  ),
                  const SizedBox(height: 20.0),
                  AuthTextField(
                    controller: _firstNameController,
                    fieldName: "Prénom",
                    passwordField: false,
                    emailField: false,
                    lastField: false,
                  ),
                  const SizedBox(height: 10.0),
                  AuthTextField(
                    controller: _lastNameController,
                    fieldName: "Nom",
                    passwordField: false,
                    emailField: false,
                    lastField: false,
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
                    controller: _userNameController,
                    fieldName: "Nom d'utilisateur",
                    passwordField: false,
                    emailField: false,
                    lastField: false,
                  ),
                  const SizedBox(height: 10.0),
                  DateTextField(
                    controller: _birthdateController,
                    fieldName: "Date de naissance (YYYY-MM-DD)",
                  ),
                  const SizedBox(height: 10.0),
                  AuthTextField(
                    controller: _passwordController,
                    fieldName: "Mot de passe",
                    passwordField: true,
                    confirmPasswordField: false,
                    emailField: false,
                    lastField: false,
                  ),
                  const SizedBox(height: 10.0),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    fieldName: "Confirmation du mot de passe",
                    passwordController: _passwordController,
                    passwordField: true,
                    confirmPasswordField: true,
                    emailField: false,
                    lastField: true,
                  ),
                  const SizedBox(height: 20.0),
                  OutlinedButton(
                    style: Theme.of(context).filledButtonTheme.style,
                    onPressed: onClickRegistrationButton,
                    child: Text(
                      "suivant".toUpperCase(),
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

  void onClickRegistrationButton() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserDto userDto = UserDto(
          firstname: _firstNameController.text.trim(),
          lastname: _lastNameController.text.trim(),
          username: _userNameController.text.trim(),
          password: _passwordController.text.trim(),
          email: _emailController.text.trim(),
          birthday: _birthdateController.text.trim(),
          avatar: _imageFile,
        );
        RegisterSecond.navigateTo(context, userDto);
      } catch (err) {
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message: err.toString(),
          messageType: MessageType.error,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      Navigator.pop(context);
    }
  }
}
