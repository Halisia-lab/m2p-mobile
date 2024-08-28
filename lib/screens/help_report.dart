import 'package:flutter/material.dart';

import '../common/user_interface_dialog.utils.dart';
import '../common/validators.dart';

class HelpReport extends StatefulWidget {
  const HelpReport({Key? key}) : super(key: key);

  static const String routeName = '/help_report';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<HelpReport> createState() => _HelpReportState();
}

class _HelpReportState extends State<HelpReport> {
  final List<String> subject = <String>[
    'GPS et réseau',
    'Signalement de place',
    'Itinéraire',
    'Carte',
    'Mon compte',
    'Commentaires et suggestions',
    'Autre',
  ];
  String? _labelText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signaler un problème'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nous sommes là pour vous aider",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton(
                padding: EdgeInsets.symmetric(horizontal: 20),
                hint: _labelText == null
                    ? Text(
                        'Sélectionnez un sujet',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _labelText!,
                        style: TextStyle(color: Colors.black),
                      ),
                items: subject.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _labelText = value;
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                underline: Container(
                  color: Colors.transparent,
                ),
                isExpanded: true,
                dropdownColor: Colors.grey.shade500,
              ),
            ),
            _labelText != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 10, left: 10, right: 10),
                        child: Text(
                          "Détails :",
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _detailsController,
                            validator: (value) {
                              return Validator.validateForm(value ?? "");
                            },
                            maxLines: 5,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Entrez votre problème',
                              hintStyle: TextStyle(
                                color: Colors.black,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onPressedSend,
                          child: Text(
                            'Envoyer',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  void onPressedSend() async {
    if (_labelText != null) {
      if (_formKey.currentState!.validate()) {
        UserInterfaceDialog.displaySnackBar(
          context: context,
          message: "Votre problème a été envoyé avec succès",
          messageType: MessageType.success,
        );
        Navigator.pop(context);
      }
    }
  }
}
