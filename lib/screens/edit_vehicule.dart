import 'package:flutter/material.dart';
import 'package:m2p/services/vehicle.dart';

import '../common/user_interface_dialog.utils.dart';
import '../components/selector.dart';
import '../exceptions/not_found.exception.dart';
import '../main.dart';
import '../models/vehicle.dart';
import '../screens/profile.dart';
import '../services/user.dart';

class EditVehicule extends StatefulWidget {
  final int vehicleId;
  const EditVehicule({Key? key, required this.vehicleId}) : super(key: key);

  static const String routeName = '/edit_vehicule';

  static void navigateTo(BuildContext context, int vehicleId) {
    Navigator.of(context).pushNamed(routeName, arguments: vehicleId);
  }

  @override
  State<EditVehicule> createState() => _EditVehiculeState();
}

class _EditVehiculeState extends State<EditVehicule> {
  final _vehicleTypeController = TextEditingController();
  final _vehicleUsageController = TextEditingController();

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
              "Modifier mon véhicule",
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: OutlinedButton(
            style: Theme.of(context).filledButtonTheme.style,
            onPressed: onPressedModificationButton,
            child: Text(
              "modifier".toUpperCase(),
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

  void onPressedModificationButton() async {
    try {
      var token = await storage.read(key: "token");
      _mapIndexToVehicleType(_vehicleTypeController);
      _mapIndexToVehicleUsage(_vehicleUsageController);
      Vehicle vehicle = Vehicle(
        id: widget.vehicleId,
        type: _vehicleTypeController.text,
        usage: _vehicleUsageController.text,
      );
      await VehicleService.updateVehicle(token!, vehicle);
      UserInterfaceDialog.displaySnackBar(
        context: context,
        message: "Modification réussie",
        messageType: MessageType.success,
      );
      _getUser().then((user) {
        Profile.popNavigateTo(context, user);
      });
    } catch (err) {
      if (err is NotFoundException) {
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
