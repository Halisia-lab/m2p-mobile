import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../common/user_interface_dialog.utils.dart';
import '../common/validators.dart';
import '../components/date_text_field.dart';
import '../components/profile_image_picker.dart';
import '../exceptions/conflict.exception.dart';
import '../exceptions/not_found.exception.dart';
import '../main.dart';
import '../models/user.dart';
import '../models/user_dto.dart';
import '../screens/profile.dart';
import '../services/user.dart';

class EditProfile extends StatefulWidget {
  final User user;

  const EditProfile({Key? key, required this.user}) : super(key: key);

  static const String routeName = '/edit_profile';

  static void navigateTo(BuildContext context, User user) {
    Navigator.of(context).pushNamed(routeName, arguments: user);
  }

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _birthdateController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstname;
    _lastNameController.text = widget.user.lastname;
    _emailController.text = widget.user.email;
    _userNameController.text = widget.user.username;
    _birthdateController.text = widget.user.birthday!;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
    _birthdateController.dispose();
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
                    "Modifier mon profil",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: ProfileImagePicker(
                        pickImage: _pickImage, imageFile: _imageFile, imageUrl: widget.user.avatar),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: "Prénom",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      return Validator.validateForm(value ?? "");
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: "Nom",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      return Validator.validateForm(value ?? "");
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      return Validator.validateEmail(value ?? "");
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    controller: _userNameController,
                    decoration: InputDecoration(
                      labelText: "Nom d'utilisateur",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      return Validator.validateForm(value ?? "");
                    },
                  ),
                  const SizedBox(height: 10.0),
                  DateTextField(
                    controller: _birthdateController,
                    fieldName: "Date de naissance (YYYY-MM-DD)",
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
        UserDto userDto = UserDto(
            firstname: _firstNameController.text.trim(),
            lastname: _lastNameController.text.trim(),
            username: _userNameController.text.trim(),
            email: _emailController.text.trim(),
            birthday: _birthdateController.text.trim(),
            avatar: _imageFile);
        await UserService.updateUser(token!, userDto);
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message: "Modification réussie",
          messageType: MessageType.success,
        );
        _getUser().then((user) {
          Profile.popNavigateTo(context, user);
        });
      } catch (err) {
        if (err is ConflictException) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: "Ce mail ou nom d'utilisateur est déjà utilisé",
            messageType: MessageType.error,
          );
        } else if (err is NotFoundException) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message:
                "Échec de la modification (réessayer plus tard ou contacter nous si le problème persiste)",
            messageType: MessageType.error,
          );
        } else if (err.toString().contains("500")) {
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message:
                "Échec de la modification (réessayer plus tard ou contacter nous si le problème persiste)",
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

  Future _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      Navigator.pop(context);
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
