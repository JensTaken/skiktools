import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skiktools/firebase_options.dart';
import 'package:skiktools/haccp.dart';
import 'package:skiktools/printpage.dart';
import 'package:skiktools/randomgen.dart';
import 'package:skiktools/singlesticker.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  List<dynamic> basisProducten = [];
  List<String> medewerkers = [];

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final doc = await FirebaseFirestore.instance.collection('config').doc('basisproducten').get();
  final medewerkersdoc = await FirebaseFirestore.instance.collection('config').doc('medewerkers').get();
  if (doc.exists && doc.data() != null) {
    final data = doc.data()!;
    final List<dynamic> productenRaw = data['producten'] ?? [];
    final List<Map<String, dynamic>> producten = productenRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    basisProducten = producten;
  }
  if (medewerkersdoc.exists && medewerkersdoc.data() != null) {
    final data = medewerkersdoc.data()!;
    final List<dynamic> medewerkersraw = data['medewerkers'] ?? [];
    medewerkers = medewerkersraw.map((e) => e.toString()).toList();
  }
  runApp(MyApp(basisProducten: basisProducten, medewerkers: medewerkers));
}



class MyApp extends StatelessWidget {
  final List<dynamic> basisProducten;
  final List<String> medewerkers; 
  const MyApp({super.key, required this.basisProducten, required this.medewerkers});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'Skik Tools',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('nl', 'NL'),
      ],
       theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          primary: Colors.black,
          secondary: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: ResponsiveLayout(basisProducten: basisProducten, medewerkers: medewerkers,),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final List<dynamic> basisProducten;
  final List<String> medewerkers; 
  const ResponsiveLayout({super.key, required this.basisProducten, required this.medewerkers});
  
  List<Widget> get widgets => [
    SingleStickerWidget(medewerkers: medewerkers),
    HaccpChecklistPage(initialDate: "2025-10-05", medewerkers: medewerkers, maxlines: 1,),
    PrintPage(medewerkers: medewerkers, producten: basisProducten,),
  ];

  void _openHaccpPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HaccpChecklistPage(
          medewerkers: medewerkers,
          maxlines: 10,
          initialDate: "2025-10-05",
        ),
      ),
    );
  }

  Widget haccpWidget(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Card(
        child: Stack(
          children: [
            Positioned.fill(child: IgnorePointer(child: widgets[1])),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openHaccpPage(context),
                  splashColor: Colors.black12,
                  highlightColor: Colors.black12,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: const Text(
                          "Open volledig",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 870) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: constraints.maxHeight - 32,              
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 340, child: widgets[0],
                            ),
                            haccpWidget(context)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: widgets[2]),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widgets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: index == 1 ? haccpWidget(context): SizedBox(
                    height: index == 0 ? 340 : (index == 1 ? 500 : 440), 
                    child: widgets[index],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}