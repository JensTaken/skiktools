import 'dart:io';
import 'package:flutter/material.dart';


class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  final List<Map<String, dynamic>> basisProducten = [
    {"naam": "Brood", "dagen": 1, "bediening": false},
    {"naam": "Burger brood", "dagen": 1, "bediening": false},
    {"naam": "Knoflooksaus", "dagen": 6, "bediening": false},
    {"naam": "Kruidenboter", "dagen": 10, "bediening": false},
    {"naam": "Gegr. Champ", "dagen": 4, "bediening": false},
    {"naam": "Cheddar geraspt", "dagen": 7, "bediening": false},
    {"naam": "Mozazarella", "dagen": 5, "bediening": false},
    {"naam": "Serranoham", "dagen": 7, "bediening": false},
    {"naam": "Oosters plateau", "dagen": 60, "bediening": false},
    {"naam": "Wakame", "dagen": 2, "bediening": false},
    {"naam": "Chilisaus", "dagen": 27, "bediening": false},
    {"naam": "Carpaccio ontdooit", "dagen": 2, "bediening": false},
    {"naam": "Carpaccio kaas", "dagen": 7, "bediening": false},
    {"naam": "Gefrituurde uitjes", "dagen": 20, "bediening": false},
    {"naam": "Zongedroogde tomaat", "dagen": 7, "bediening": false},
    {"naam": "Truffelmayo", "dagen": 27, "bediening": false},
    {"naam": "Nachos", "dagen": 7, "bediening": false},
    {"naam": "Pulled chicken", "dagen": 5, "bediening": false},
    {"naam": "Tomatensoep", "dagen": 3, "bediening": false},
    {"naam": "Slagroom", "dagen": 2, "bediening": true},
    {"naam": "Soepballen", "dagen": 3, "bediening": false},
    {"naam": "Schnitzel", "dagen": 1, "bediening": false},
    {"naam": "Boerengarn.", "dagen": 4, "bediening": false},
    {"naam": "Pepersaus", "dagen": 3, "bediening": false},
    {"naam": "Champ roomsaus", "dagen": 3, "bediening": false},
    {"naam": "Citroenen", "dagen": 2, "bediening": true},
    {"naam": "Limoen", "dagen": 2, "bediening": true},
    {"naam": "Sinasappel", "dagen": 2, "bediening": true},
    {"naam": "Glaze", "dagen": 7, "bediening": false},
    {"naam": "Chimichuri", "dagen": 7, "bediening": false},
    {"naam": "Groente", "dagen": 1, "bediening": false},
    {"naam": "Sesamzaad", "dagen": 30, "bediening": false},
    {"naam": "Gambas", "dagen": 1, "bediening": false},
    {"naam": "Quiche", "dagen": 3, "bediening": false},
    {"naam": "Gefr uitjes", "dagen": 30, "bediening": false},
    {"naam": "Crème fraîche", "dagen": 4, "bediening": false},
    {"naam": "Cheddar", "dagen": 7, "bediening": false},
    {"naam": "Spies 200", "dagen": 2, "bediening": false},
    {"naam": "Spies 150", "dagen": 2, "bediening": false},
    {"naam": "Friet", "dagen": 1, "bediening": false},
    {"naam": "Roseval", "dagen": 3, "bediening": false},
    {"naam": "Sla", "dagen": 1, "bediening": false},
    {"naam": "Tomaat", "dagen": 2, "bediening": false},
    {"naam": "Komkommer", "dagen": 2, "bediening": false},
    {"naam": "Rode ui", "dagen": 3, "bediening": false},
    {"naam": "Honing mosterd", "dagen": 28, "bediening": false},
    {"naam": "Balsamicodressing", "dagen": 31, "bediening": false},
    {"naam": "Cocktailsaus", "dagen": 30, "bediening": false},
    {"naam": "Geitenkaas", "dagen": 10, "bediening": false},
    {"naam": "Walnoten", "dagen": 30, "bediening": false},
    {"naam": "Vijgen", "dagen": 4, "bediening": false},
    {"naam": "Burgers", "dagen": 5, "bediening": false},
    {"naam": "Burgerrelish", "dagen": 27, "bediening": false},
    {"naam": "Augurk", "dagen": 7, "bediening": false},
    {"naam": "Bacon", "dagen": 7, "bediening": false},
    {"naam": "Creamy baconsaus", "dagen": 27, "bediening": false},
    {"naam": "Kipburgers", "dagen": 1, "bediening": false},
    {"naam": "Tzatziki", "dagen": 5, "bediening": false},
    {"naam": "Avocado burgers", "dagen": 33, "bediening": false},
    {"naam": "Smockey hemp saus", "dagen": 29, "bediening": false},
    {"naam": "Ham", "dagen": 2, "bediening": false},
    {"naam": "Kaas", "dagen": 2, "bediening": false},
    {"naam": "Eiersalade", "dagen": 4, "bediening": false},
    {"naam": "Brandermayo", "dagen": 28, "bediening": false},
    {"naam": "Kroketten", "dagen": 35, "bediening": false},
    {"naam": "Mosterd", "dagen": 30, "bediening": false},
    {"naam": "Tonijnsalade", "dagen": 3, "bediening": false},
    {"naam": "Curry", "dagen": 27, "bediening": false},
    {"naam": "Kipfilet", "dagen": 2, "bediening": false},
    {"naam": "Bitterballen", "dagen": 37, "bediening": false},
    {"naam": "Advocaatsaus", "dagen": 30, "bediening": false},
    {"naam": "Monchou", "dagen": 3, "bediening": false},
    {"naam": "Bastogne", "dagen": 10, "bediening": true},
    {"naam": "Kersen", "dagen": 4, "bediening": false},
    {"naam": "Choco saus", "dagen": 30, "bediening": false},
    {"naam": "Lava cake", "dagen": 10, "bediening": false},
    {"naam": "Rood fruit", "dagen": 5, "bediening": false},
    {"naam": "Aardbeisaus", "dagen": 29, "bediening": true},
    {"naam": "Karamelsaus", "dagen": 39, "bediening": true},
    {"naam": "Monchou bediening", "dagen": 1, "bediening": true},
    {"naam": "Munt", "dagen": 4, "bediening": true},
    {"naam": "Melk", "dagen": 3, "bediening": true},
    {"naam": "Macarons", "dagen": 5, "bediening": true},
  ];
  
  final List<String> medewerkers = ["Jens", "Isa", "Tyan", "Bediening", "Keuken", "Mik", "Marit", "Timo", "Rolf", "Daan", "Hidde", "Stijn", "Eva"];
  String geselecteerdeMedewerker = "";
  final List<Map<String, dynamic>> printLijst = [];
  bool isPrinting = false; // Prevent double printing

  @override
  void initState() {
    super.initState();
    // Voeg alle basis producten toe aan de printlijst
    for (var product in basisProducten) {
      printLijst.add({
        'naam': product['naam'],
        'wegOpDatum': DateTime.now().add(Duration(days: product['dagen'])),
        'gevinkt': false,
        'standaardDagen': product['dagen'],
        'aantal': 1,
        'parentIndex': null, // Voor het tracken van parent-child relaties
      });
    }
    medewerkers.shuffle();
    geselecteerdeMedewerker = medewerkers.first; // Standaard medewerker
  }

  String formatDutchDate(DateTime date) {
    const dutchDays = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];
    const dutchMonths = [
      'Jan', 'Feb', 'Mrt', 'Apr', 'Mei', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dec'
    ];
    
    final dayName = dutchDays[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = dutchMonths[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$dayName $day $month $hour:$minute';
  }

  Future<int> printLabel(String naam, DateTime wegOpDatum, String medewerker) async {
    final String formattedDate = formatDutchDate(wegOpDatum);
    final String wegOpTekst = "Weg op:";

    final result = await Process.run(
      'python',
      [
        'print.py',
        naam,
        formattedDate,
        wegOpTekst,
        medewerker
      ],
    );
    return result.exitCode;
  }

  Future<void> bulkPrint() async {
    if (isPrinting) return; // Prevent double printing
    setState(() {
      isPrinting = true;
    });
    final gevinkteItems = printLijst.where((item) => item['gevinkt'] == true).toList();
    
    if (gevinkteItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geen items geselecteerd om te printen'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        isPrinting = false;
      });
      return;
    }

    int totalLabels = 0;
 
    try {
      for (var item in gevinkteItems) {
        final aantal = item['aantal'] as int;
        
        // Print multiple labels based on quantity
        for (int i = 0; i < aantal; i++) {
          var code = await printLabel(item['naam'], item['wegOpDatum'], geselecteerdeMedewerker);
          if (code != 0) {
            throw Exception('Fout bij printen van ${item['naam']}: $code');
          }
        }
        totalLabels += aantal;
      }

      // Uncheck geprinte items maar laat ze in de lijst staan
      setState(() {
        for (var item in printLijst) {
          if (item['gevinkt'] == true) {
            item['gevinkt'] = false;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $totalLabels labels succesvol geprint!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Fout bij printen: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isPrinting = false;
      });
    }
  }

  void voegDuplicaatToe(String naam, int standaardDagen, int originalIndex) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime geselecteerdeDatum = DateTime.now().add(Duration(days: standaardDagen));
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Extra $naam toevoegen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Houdbaar tot:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final datum = await showDatePicker(
                        context: context,
                        initialDate: geselecteerdeDatum,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (datum != null) {
                        final tijd = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(geselecteerdeDatum),
                        );
                        if (tijd != null) {
                          setDialogState(() {
                            geselecteerdeDatum = DateTime(
                              datum.year,
                              datum.month,
                              datum.day,
                              tijd.hour,
                              tijd.minute,
                            );
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(formatDutchDate(geselecteerdeDatum)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Find the position to insert (right after the original item and its existing duplicates)
                      int insertIndex = originalIndex + 1;
                      while (insertIndex < printLijst.length && 
                             printLijst[insertIndex]['parentIndex'] == originalIndex) {
                        insertIndex++;
                      }
                      
                      printLijst.insert(insertIndex, {
                        'naam': naam,
                        'wegOpDatum': geselecteerdeDatum,
                        'gevinkt': false,
                        'standaardDagen': standaardDagen,
                        'isDuplicaat': true,
                        'aantal': 1,
                        'parentIndex': originalIndex,
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Toevoegen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateAantal(int index, int delta) {
    setState(() {
      final currentAantal = printLijst[index]['aantal'] as int;
      final newAantal = (currentAantal + delta).clamp(1, 99);
      printLijst[index]['aantal'] = newAantal;
    });
  }

  Widget buildCounterWidget(int index, int aantal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: aantal > 1 ? () => updateAantal(index, -1) : null,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: aantal > 1 ? Colors.red[50] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 18,
                color: aantal > 1 ? Colors.red[700] : Colors.grey[400],
              ),
            ),
          ),
          Container(
            width: 50,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                vertical: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Text(
              aantal.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          InkWell(
            onTap: aantal < 99 ? () => updateAantal(index, 1) : null,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: aantal < 99 ? Colors.green[50] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 18,
                color: aantal < 99 ? Colors.green[700] : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Bulk printen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            // Employee selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.black),
                  const SizedBox(width: 12),
                  const Text(
                    'Medewerker:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: geselecteerdeMedewerker,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: medewerkers
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            geselecteerdeMedewerker = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Product list
            Expanded(
              child: ListView.builder(
                itemCount: printLijst.length,
                itemBuilder: (context, index) {
                  final item = printLijst[index];
                  final isDuplicaat = item['isDuplicaat'] ?? false;
                  final aantal = item['aantal'] as int;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: item['gevinkt'] ? Colors.blue[300]! : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Checkbox
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: item['gevinkt'],
                                onChanged: (value) {
                                  setState(() {
                                    printLijst[index]['gevinkt'] = value ?? false;
                                  });
                                },
                                activeColor: Colors.blue[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Product info
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (isDuplicaat) 
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'EXTRA',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        child: Text(
                                          item['naam'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Weg op: ${formatDutchDate(item['wegOpDatum'])}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Counter
                            buildCounterWidget(index, aantal),
                            
                            const SizedBox(width: 12),
                            
                            // Action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Add duplicate button
                                IconButton(
                                  onPressed: () => voegDuplicaatToe(
                                    item['naam'], 
                                    item['standaardDagen'],
                                    isDuplicaat ? item['parentIndex'] ?? index : index,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: Colors.black,
                                  tooltip: 'Extra toevoegen',
                                ),
                                
                                // Delete button (only for duplicates)
                                if (isDuplicaat)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        printLijst.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                    color: Colors.red[600],
                                    tooltip: 'Verwijderen',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              width: double.infinity,
        
        child: ElevatedButton.icon(
          onPressed: isPrinting ? null : bulkPrint,
          icon: isPrinting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.print),
          label: Text(isPrinting ? 'Printen...' : 'Print'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrinting ? Colors.grey : Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
   
          ],
        ));
  }
}