import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skiktools/constants.dart';

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  String geselecteerdeMedewerker = "";
  final List<Map<String, dynamic>> printLijst = [];
  bool isPrinting = false;
  dynamic selectedCategorie;
  List<dynamic> categorieen = [];

  @override
  void initState() {
    super.initState();
    medewerkers.shuffle();
    loadProducten();
    geselecteerdeMedewerker = medewerkers.first;
    extractCategorieen();
  }

  void extractCategorieen() {
    // Collect unique categories from basisProducten
    final set = <dynamic>{};
    for (var product in basisProducten) {
      if (product['categorie'] != null) set.add(product['categorie']);
    }
    categorieen = set.toList();
    categorieen.sort((a, b) => a.toString().compareTo(b.toString()));
    categorieen.insert(0, null); // For "Alle"
    selectedCategorie = null;
  }

  void loadProducten() {
    for (var product in basisProducten) {
      printLijst.add({
        'naam': product['naam'],
        'wegOpDatum': DateTime.now().add(Duration(days: product['dagen'])),
        'gevinkt': false,
        'standaardDagen': product['dagen'],
        'aantal': 1,
        'bediening': product['bediening'] ?? false,
        'parentIndex': null,
        'categorie': product['categorie'], // Add category
      });
    }
    setState(() {});
    printLijst.sort((a, b) => a['naam'].toLowerCase().compareTo(b['naam'].toLowerCase()));
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
    await Future.delayed(const Duration(milliseconds: 100));
    final String formattedDate = formatDutchDate(wegOpDatum);
    final String wegOpTekst = "Weg op:";

    final result = await Process.run(
      r'C:\Users\Horeko\AppData\Local\Programs\Python\Python313\python.exe',
      [
        r'C:\Program Files\Skiktools\print.py',
        naam,
        formattedDate,
        wegOpTekst,
        medewerker
      ],
    );
    return result.exitCode;
  }

  Future<void> bulkPrint() async {
    if (isPrinting) return; 
    setState(() {
      isPrinting = true;
    });
    final gevinkteItems = printLijst.where((item) {
      // Filter by category if selected
      if (selectedCategorie != null) {
        return item['gevinkt'] == true && item['categorie'] == selectedCategorie;
      }
      return item['gevinkt'] == true;
    }).toList();
    
    if (gevinkteItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ben je kaulo dom ofz? Selecteer eerst items om te printen daggoe!'),
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
        for (int i = 0; i < aantal; i++) {
          var code = await printLabel(item['naam'], item['wegOpDatum'], geselecteerdeMedewerker);
          if (code != 0) {
            throw Exception('Kon ${item['naam']} niet printen: $code');
          }
        }
        totalLabels += aantal;
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Die tering printer doet het niet: ${e.toString()}'),
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
                      
                      int insertIndex = originalIndex + 1;
                      while (insertIndex < printLijst.length && 
                             printLijst[insertIndex]['parentIndex'] == originalIndex) {
                        insertIndex++;
                      }
                      printLijst.insert(insertIndex-1, {
                        'naam': naam,
                        'wegOpDatum': geselecteerdeDatum,
                        'gevinkt': false,
                        'standaardDagen': standaardDagen,
                        'isDuplicaat': true,
                        'aantal': 1,
                        'parentIndex': originalIndex,
                        'categorie': printLijst[originalIndex]['categorie'],
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
    // Filtered list by category
    final filteredList = selectedCategorie == null
        ? printLijst
        : printLijst.where((item) => item['categorie'] == selectedCategorie).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: geselecteerdeMedewerker,
                    isExpanded: true,
                    menuMaxHeight: 200,
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
          const SizedBox(height: 8),
          
          // Category slider
          Row(
            children: [
              // Category slider
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categorieen.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = categorieen[idx];
                      final isSelected = cat == selectedCategorie;
                      return ChoiceChip(
                        label: Text(
                          cat == null ? "Alle" : cat.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedCategorie = cat;
                          });
                        },
                        selectedColor: Colors.black,
                        backgroundColor: Colors.grey[200],
                        side: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Deselect all button
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                 setState(() {
                   selectedCategorie = null;
                   for (var item in printLijst) {
                     item['gevinkt'] = false;
                   }
                 });
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text("Deselecteer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final isDuplicaat = item['isDuplicaat'] ?? false;
                final aantal = item['aantal'] as int;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: item['gevinkt'] ? Colors.grey[700]! : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: item['gevinkt'],
                              onChanged: (value) {
                                setState(() {
                                  // Find the item in printLijst and update
                                  final idx = printLijst.indexOf(item);
                                  if (idx != -1) printLijst[idx]['gevinkt'] = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          
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
                                          'ANDERE \nDATUM',
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
                          
                          
                          buildCounterWidget(printLijst.indexOf(item), aantal),
                          
                          const SizedBox(width: 12),
                          
                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              
                              IconButton(
                                onPressed: () => voegDuplicaatToe(
                                  item['naam'], 
                                  item['standaardDagen'],
                                  isDuplicaat ? item['parentIndex'] ?? printLijst.indexOf(item) : printLijst.indexOf(item),
                                ),
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.black,
                                tooltip: 'Extra toevoegen',
                              ),
                              
                              
                              if (isDuplicaat)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      printLijst.remove(item);
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
      ),
    );
  }
}