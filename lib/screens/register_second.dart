import 'package:flutter/material.dart';
import 'package:m2p/screens/login_or_register.dart';
import 'package:m2p/services/auth.dart';

import '../common/user_interface_dialog.utils.dart';
import '../components/selector.dart';
import '../exceptions/conflict.exception.dart';
import '../exceptions/not_found.exception.dart';
import '../models/user_dto.dart';

class RegisterSecond extends StatefulWidget {
  final UserDto user;

  const RegisterSecond({Key? key, required this.user}) : super(key: key);

  static const String routeName = '/register-second';

  static void navigateTo(BuildContext context, UserDto user) {
    Navigator.of(context).pushNamed(routeName, arguments: user);
  }

  @override
  State<RegisterSecond> createState() => _RegisterSecondState();
}

class _RegisterSecondState extends State<RegisterSecond> {
  final _vehicleTypeController = TextEditingController();
  final _vehicleUsageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehicleUsageController.dispose();
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
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              "Inscription",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20.0),
            Selector(
                label: "Type de véhicule : ",
                childrens: [
                  Tab(
                    icon: Icon(Icons.directions_car),
                  ),
                  Tab(
                    icon: Icon(Icons.directions_bus),
                  ),
                  Tab(
                    icon: Icon(Icons.directions_bike),
                  ),
                ],
                controller: _vehicleTypeController),
            const SizedBox(height: 20.0),
            Selector(
                label: "Utilisation : ",
                childrens: [
                  Tab(text: "PARTICULIER"),
                  Tab(text: "PROFESSIONEL"),
                ],
                controller: _vehicleUsageController),
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
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: OutlinedButton(
            style: Theme.of(context).filledButtonTheme.style,
            onPressed: onPressInscriptionButton,
            child: Text(
              "inscription".toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
      ),
    );
  }

  void _mapIndexToVehicleType(TextEditingController controller) {
    switch (controller.text) {
      case "0":
        controller.text = "car";
        break;
      case "1":
        controller.text = "utility";
        break;
      case "2":
        controller.text = "moto";
        break;
      default:
        controller.text = "car";
    }
  }

  void _mapIndexToVehicleUsage(TextEditingController controller) {
    switch (controller.text) {
      case "0":
        controller.text = "individual";
        break;
      case "1":
        controller.text = "professional";
        break;
      default:
        controller.text = "individual";
    }
  }

  void onPressInscriptionButton() async {
    try {
      setState(() {
        _isLoading = true;
      });
      _mapIndexToVehicleType(_vehicleTypeController);
      _mapIndexToVehicleUsage(_vehicleUsageController);
      widget.user.updateVehicle(_vehicleTypeController.text.trim(), _vehicleUsageController.text.trim());
      await AuthService.register(widget.user);
      UserInterfaceDialog.displaySnackBar(
        context: context,
        message: "Inscription réussie, activer votre compte via le lien envoyé à votre adresse mail",
        messageType: MessageType.success,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
            (route) => false,
      );
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
              "Échec de l'inscription (réessayer plus tard ou contacter nous si le problème persiste)",
          messageType: MessageType.error,
        );
      } else if (err.toString().contains("500")) {
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message:
              "Échec de l'inscription (réessayer plus tard ou contacter nous si le problème persiste)",
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
