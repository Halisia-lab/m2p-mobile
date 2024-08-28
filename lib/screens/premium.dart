import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:m2p/main.dart';
import 'package:m2p/services/user.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../common/user_interface_dialog.utils.dart';

class Premium extends StatefulWidget {
  const Premium({Key? key}) : super(key: key);

  static const String routeName = '/premium';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<Premium> createState() => _PremiumState();
}

class _PremiumState extends State<Premium> {
  PanelController _pc = new PanelController();
  final InAppPurchase _iap = InAppPurchase.instance;
  final String _productID = 'premium';

  bool _available = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  String _price = '6. 99';

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      setState(() {
        _purchases.addAll(purchaseDetailsList);
        _listenToPurchaseUpdated(purchaseDetailsList);
      });
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      _subscription?.cancel();
    });
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
      ),
      body: SlidingUpPanel(
        backdropEnabled: true,
        controller: _pc,
        minHeight: MediaQuery.of(context).size.height * 0.12,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
        panel: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Confirmer",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "Vous êtes sur le point de rejoindre Map2Place Premium.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                "La somme de $_price €/mois vous sera facturée à partir "
                "d'aujourd'hui. Annulez votre abonnement sans frais ni pénalités.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "En rejoignant Map2Place Premium, vous autorisez Map2Place "
                "à vous facturer $_price € à partir d'aujourd'hui, puis "
                "chaque mois après cela. Vous pouvez annuler depuis "
                "l'application votre abonnement à tout moment.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
            _available
                ? Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return _buildProduct(product: _products[index]);
                        },
                      ),
                    ],
                  )
                : Center(
                    child: Text("Le Shop est indisponible pour le moment"),
                  ),
          ],
        ),
        collapsed: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(25.0),
          child: TextButton(
            onPressed: () => _pc.open(),
            child: Text(
              "Rejoignez Map2Place Premium",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Map2Place Premium",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.acme().fontFamily,
                ),
              ),
              Text(
                "$_price € / mois",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.acme().fontFamily,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Map2Places Premium est un abonnement qui vous permet de "
                "profiter de toutes les fonctionnalités de l'application "
                "Map2Places.",
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.looks_one, size: 30,),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      "Affectation prioritaire aux places désirées",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.search, size: 30,),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      "Recherche plus précise de l'emplacement des places disponibles",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.info, size: 30,),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      "Information plus détaillée sur les places disponibles",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Icon(Icons.shield, size: 30,),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      "Résiliez votre abonnement sans frais ni pénalités",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _initialize() async {
    _available = await _iap.isAvailable();
    List<ProductDetails> products = await _getProducts(
      productIds: Set<String>.from([_productID]),
    );
    setState(() {
      _products = products;
      _price = _products[0].price.substring(1);
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: purchaseDetails.error!.message,
            messageType: MessageType.error,
          );
          break;
        case PurchaseStatus.purchased:
          var token = await storage.read(key: 'token');
          await UserService.updateUserPremium(token!, true);
          UserInterfaceDialog.displaySnackBar(
            context: context,
            message: "Félicitations, vous faite partie désormais de Map2Place Premium !",
            messageType: MessageType.success
          );
          break;
        case PurchaseStatus.restored:
          break;
        case PurchaseStatus.canceled:
          var token = await storage.read(key: 'token');
          await UserService.updateUserPremium(token!, false);
          break;
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
        var token = await storage.read(key: 'token');
        await UserService.updateUserPremium(token!, true);
      }
    });
  }

  Future _getProducts({required Set<String> productIds}) async {
    ProductDetailsResponse response = await _iap.queryProductDetails(productIds);
    return response.productDetails;
  }

  ListTile _buildProduct({required ProductDetails product}) {
    return ListTile(
      title: ElevatedButton(
        onPressed: () {
          _subscribe(product: product);
        },
        child: Text('Accepter'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
          fixedSize: MaterialStateProperty.all<Size>(Size(100, 50)),
        ),
      ),
    );
  }

  void _subscribe({required ProductDetails product}) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
