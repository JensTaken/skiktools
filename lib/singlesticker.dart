import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class SingleStickerWidget extends StatefulWidget {
  const SingleStickerWidget({super.key});

  @override
  State<SingleStickerWidget> createState() => _SingleStickerWidgetState();
}

class _SingleStickerWidgetState extends State<SingleStickerWidget> {
  final TextEditingController _nameController = TextEditingController();
  bool _isPrinting = false;
  DateTime _selectedDate = DateTime.now();
  final List<String> medewerkers = ["Jens", "Isa", "Tyan", "Bediening", "Keuken", "Mik", "Marit", "Timo", "Rolf", "Daan", "Hidde", "Stijn", "Eva", "Wytze"];
  String? _selectedEmployee;
 
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    medewerkers.shuffle();
    _selectedEmployee = medewerkers.first;
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
  Future<void> _selectDate(BuildContext context) async {
  final datum = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  if (datum != null) {
    final tijd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (tijd != null) {
      setState(() {
        _selectedDate = DateTime(
          datum.year,
          datum.month,
          datum.day,
          tijd.hour,
          tijd.minute,
        );
      });
    } else {
      // Only update the date if time picker was canceled
      setState(() {
        _selectedDate = DateTime(
          datum.year,
          datum.month,
          datum.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }
}

  Future<void> _printSticker() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vul eerst een productnaam in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecteer eerst een medewerker'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      final int exitCode = await printLabel(
        _nameController.text.trim(),
        _selectedDate,
        _selectedEmployee!,
      );

      if (exitCode == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sticker voor "${_nameController.text}" succesvol geprint'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear the form after successful print
        _nameController.clear();
        _selectedDate = DateTime.now();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Die tering printer doet het niet (exit code: $exitCode)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Die tering printer doet het niet: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isPrinting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Text(
                'HACCP Sticker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            const SizedBox(height: 10),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Productnaam...',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    
                    // Divider line
                    Container(
                      height: 1,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    
                    // "Weg op:" label
                    const Text(
                      'Weg op:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Date - clickable
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatDutchDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: DropdownButtonFormField<String>(
                        value: _selectedEmployee,
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
                          hintText: 'Selecteer medewerker...',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                       
                        items: medewerkers.map((String employee) {
                          return DropdownMenuItem<String>(
                            value: employee,
                            child: Text(employee),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedEmployee = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            // Print button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isPrinting ? null : _printSticker,
                icon: _isPrinting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.print, size: 18),
                label: Text(
                  _isPrinting ? 'Printen...' : 'Print Sticker',
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPrinting ? Colors.grey : Colors.black,
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}