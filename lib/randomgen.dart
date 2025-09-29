import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

class TemperatureLoggerPage extends StatefulWidget {
  const TemperatureLoggerPage({super.key});

  @override
  State<TemperatureLoggerPage> createState() => _TemperatureLoggerPageState();
}

class _TemperatureLoggerPageState extends State<TemperatureLoggerPage> {
  final TextEditingController _resultController = TextEditingController();
  final Random _random = Random();
  bool show = false;

  static const List<String> productenBainMarie = [
    "Tomatensoep", "Pepersaus", "Champignonroomsaus", "Soep van de dag",
    "Soepballen", "Puree"
  ];
  
  static const List<String> productenVriezer = [
    "Pulled chicken", "Soepballen", "Schnitzel", "Kip", "Spare ribs",
    "Zalm", "Gamba's"
  ];

  void genereer(String type) {
    final List<String> producten = type == 'vriezer' ? productenVriezer : productenBainMarie;
    final String randomProduct = producten[_random.nextInt(producten.length)];
    
    double temp1, temp2, temp3;
    String tekst;
    
    if (type == 'vriezer') {
      temp1 = double.parse((_random.nextDouble() * 8 + 20).toStringAsFixed(1));
      temp2 = double.parse((_random.nextDouble() * 15 + 0).toStringAsFixed(1));
      temp3 = double.parse((_random.nextDouble() * -5 - 18).toStringAsFixed(1));
      tekst = 'Ingevroren product: $randomProduct\n'
              'Begintemperatuur: $temp1 °C\n'
              'Na 2,5 uur: $temp2 °C\n'
              'Na 5 uur: $temp3 °C\n\n'
              'Invriezen volgens richtlijnen uitgevoerd.';
    } else {
      temp1 = double.parse((_random.nextDouble() * 30 + 55).toStringAsFixed(1));
      temp2 = double.parse((_random.nextDouble() * 10 + 10).toStringAsFixed(1));
      temp3 = double.parse((_random.nextDouble() * 3 + 3.5).toStringAsFixed(1));
      tekst = 'Gemeten product: $randomProduct\n'
              'Begintemperatuur: $temp1 °C\n'
              'Temperatuur na 2,5 uur: $temp2 °C\n'
              'Temperatuur na 5 uur: $temp3 °C\n\n'
              'Terugkoelen naar behoren.';
    }
    
    setState(() {
      _resultController.text = tekst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Align(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(Icons.question_mark),
              onPressed: () {
                setState(() {
                  show = !show;
                });
              },
              
            ),
          ),
        ),
        Visibility(
          visible: show,
          child: SizedBox(height: 400,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => genereer('vriezer'),
                        icon: const Icon(Icons.ac_unit),
                        label: const Text('Vriezer\nMeting'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => genereer('bain-marie'),
                        icon: const Icon(Icons.whatshot),
                        label: const Text('Bain-Marie\nMeting'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: TextField(
                      controller: _resultController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Klik op een knop om een temperatuurmeting te genereren...',
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_resultController.text.isNotEmpty)
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _resultController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tekst gekopieerd naar klembord'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Kopieer naar Klembord'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),)
        ),
      ],
    );
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }
}