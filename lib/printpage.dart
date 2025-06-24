import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:typed_data';

class ArgoxPrinter {
  SerialPort? _port;
  
  Future<bool> connect() async {
    try {
      _port = SerialPort('COM1');
      
      final config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..stopBits = 1
        ..parity = SerialPortParity.none;
      
      _port!.config = config;
      return _port!.openReadWrite();
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }
  
  Future<void> sendPPLB(String pplbCommand) async {
    if (_port == null || !_port!.isOpen) {
      throw Exception('Printer not connected');
    }
    
    try {
      final data = Uint8List.fromList(pplbCommand.codeUnits);
      final bytesWritten = _port!.write(data);
      print('Sent $bytesWritten bytes');
      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      print('Send failed: $e');
      rethrow;
    }
  }
  
  void disconnect() {
    _port?.close();
    _port?.dispose();
    _port = null;
  }
}

class LabelPrinterService {
  final ArgoxPrinter _printer = ArgoxPrinter();
  
  Future<void> printProductLabel({
    required String productName,
    required String wegOp,
    required String medewerkername,
  }) async {
    if (!await _printer.connect()) {
      throw Exception('Failed to connect to printer');
    }
    
    try {
      // Huidige datum en tijd formatteren
      final now = DateTime.now();
      final currentDate = "${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)} ${now.year.toString().substring(2)}";
      final currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      
      // PPLB commando voor het label (58mm breed label)
      String pplbCommand = '''
"A50,30,0,1,1,1,N,\"This is font 1.\""
''';
      
      await _printer.sendPPLB(pplbCommand);
      print('Product label sent successfully');
      
    } finally {
      _printer.disconnect();
    }
  }
  
  String _getMonthName(int month) {
    const months = ['jan', 'feb', 'mrt', 'apr', 'mei', 'jun',
                   'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    return months[month - 1];
  }
}

// Voorbeeld Flutter widget voor het printen
class PrintLabelWidget extends StatefulWidget {
  @override
  _PrintLabelWidgetState createState() => _PrintLabelWidgetState();
}

class _PrintLabelWidgetState extends State<PrintLabelWidget> {
  final LabelPrinterService _printerService = LabelPrinterService();
  final _productController = TextEditingController();
  final _wegOpController = TextEditingController();
  final _medewerkernameController = TextEditingController();
  
  @override
  void dispose() {
    _productController.dispose();
    _wegOpController.dispose();
    _medewerkernameController.dispose();
    super.dispose();
  }
  
  void _printLabel() async {
    if (_productController.text.isEmpty || 
        _wegOpController.text.isEmpty || 
        _medewerkernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vul alle velden in')),
      );
      return;
    }
    
    try {
      await _printerService.printProductLabel(
        productName: _productController.text,
        wegOp: _wegOpController.text,
        medewerkername: _medewerkernameController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Label succesvol geprint!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Print fout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Label Printer'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productController,
              decoration: InputDecoration(
                labelText: 'Product naam',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _wegOpController,
              decoration: InputDecoration(
                labelText: 'Weg op (bijv. Za 20 feb 11:07)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _medewerkernameController,
              decoration: InputDecoration(
                labelText: 'Medewerker naam',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _printLabel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Print Label',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Huidige datum/tijd wordt automatisch toegevoegd',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Voorbeeldgebruik:
class ExampleUsage {
  static void printExampleLabel() async {
    final printerService = LabelPrinterService();
    
    try {
      await printerService.printProductLabel(
        productName: 'Truffelmayo',
        wegOp: 'Za 20 feb 11:07',
        medewerkername: 'Jan',
      );
    } catch (e) {
      print('Print error: $e');
    }
  }
}