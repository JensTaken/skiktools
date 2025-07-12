import 'package:flutter/material.dart';
import 'package:skiktools/printpage.dart';
import 'package:skiktools/randomgen.dart';
import 'package:skiktools/singlesticker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: ResponsiveLayout(),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  
  final List<Widget> widgets = const [
    SingleStickerWidget(),
    TemperatureLoggerPage(),
    PrintPage()
  ];

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
                              height: constraints.maxHeight < 800 ? 390 : (constraints.maxHeight / 2) - 20, 
                              child: widgets[0],
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              height: constraints.maxHeight < 800 ? 400 : (constraints.maxHeight / 2) - 40,  
                              child: widgets[1],
                            ),
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
                  child: SizedBox(
                    height: 400, 
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