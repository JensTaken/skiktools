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
      title: 'Flutter Demo',
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

  // Define your three widgets here (now only using 3 widgets)
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
          // Breakpoint for switching between grid and list
          // You can adjust this value based on your needs
          if (constraints.maxWidth > 870) {
            // Grid layout for larger screens - 2 widgets left, 1 large widget right
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Left column: 2 widgets stacked with fixed height and scrollable
                  Expanded(
                    child: SizedBox(
                      height: constraints.maxHeight - 32, // Full height minus padding
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: constraints.maxHeight < 800 ? 390 : (constraints.maxHeight / 2) - 20, // Fixed height for first widget
                              child: widgets[0],
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              height: constraints.maxHeight < 800 ? 400 : (constraints.maxHeight / 2) - 40,  // Fixed height for second widget
                              child: widgets[1],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Right column: 1 large widget
                  Expanded(child: widgets[2]),
                ],
              ),
            );
          } else {
            // ListView for smaller screens
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widgets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    height: 400, // Give each widget a fixed height
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