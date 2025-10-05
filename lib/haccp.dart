import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:skiktools/classes.dart';

class HaccpChecklistPage extends StatefulWidget {
  final List<String> medewerkers;
  final String? initialDate;
  final int maxlines;
  const HaccpChecklistPage({super.key, required this.medewerkers, this.initialDate, required this.maxlines});

  @override
  State<HaccpChecklistPage> createState() => _HaccpChecklistPageState();
}

class _HaccpChecklistPageState extends State<HaccpChecklistPage> {
  late DateTime selectedDate;
  late String geselecteerdeMedewerker;
  late Map<String, bool> checkedTasks = {};
  Map<String, DateTime?> tempStartTimes = {};
  Map<String, String> tempStart = {};
  Map<String, String> temp2h = {};
  Map<String, String> temp5h = {};
  Map<String, Set<String>> missingFields = {};
  bool closed = false;
  List<HaccpTask> haccpTasks = [];
  List<DateTime> alertDates = [];
  bool loadingAlerts = true;
  bool loadingTasks = true;
  Map<String, DateTime?> taskCompletionTimes = {};
  Map<String, String> terugkoelNamen = {};
  Map<String, String> koelkastTemperaturen = {};

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    geselecteerdeMedewerker = widget.medewerkers.isNotEmpty ? widget.medewerkers.first : '';
    _fetchAndSetTasks();
    _loadCheckedTasks();
    _checkMissingPreviousDays();
  }

  Future<List<HaccpTask>> fetchHaccpTasksFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('haccp_tasks').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return HaccpTask(
        id: data['id'] ?? doc.id,
        name: data['name'] ?? '',
        type: data['type'] ?? '',
        info: data['info'] ?? '',
        weeklyDay: data['weeklyDay'] is int
            ? data['weeklyDay']
            : (data['weeklyDay'] != null ? int.tryParse(data['weeklyDay'].toString()) : null),
      );
    }).toList();
  }

  Future<void> _fetchAndSetTasks() async {
    setState(() {
      loadingTasks = true;
    });
    haccpTasks = await fetchHaccpTasksFromFirestore();
    setState(() {
      loadingTasks = false;
    });
  }

  String get dateString => DateFormat('yyyy-MM-dd').format(selectedDate);

  Future<void> _loadCheckedTasks() async {
    final doc = await FirebaseFirestore.instance
        .collection('haccp_checklists')
        .doc(dateString)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        checkedTasks = Map<String, bool>.from(data['tasks'] ?? {});
        geselecteerdeMedewerker = data['medewerker'] ?? geselecteerdeMedewerker;
        closed = data['closed'] == true;
        final terugkoel = data['terugkoel'] ?? {};
        tempStartTimes = {};
        tempStart = {};
        temp2h = {};
        temp5h = {};
        terugkoel.forEach((taskId, values) {
          if (values is Map) {
            if (values['starttijd'] != null) {
              tempStartTimes[taskId] = DateTime.tryParse(values['starttijd']);
            }
            if (values['start'] != null) tempStart[taskId] = values['start'].toString();
            if (values['2u'] != null) temp2h[taskId] = values['2u'].toString();
            if (values['5u'] != null) temp5h[taskId] = values['5u'].toString();
          }
        });
        // Load completion times
        final times = data['completionTimes'] ?? {};
        taskCompletionTimes = {};
        times.forEach((k, v) {
          if (v != null) {
            taskCompletionTimes[k] = DateTime.tryParse(v);
          }
        });
        // Load extra fields
        terugkoelNamen = Map<String, String>.from(data['terugkoelNamen'] ?? {});
        koelkastTemperaturen = Map<String, String>.from(data['koelkastTemperaturen'] ?? {});
      });
    } else {
      setState(() {
        checkedTasks = {};
        tempStartTimes = {};
        tempStart = {};
        temp2h = {};
        temp5h = {};
        closed = false;
        taskCompletionTimes = {};
        terugkoelNamen = {};
        koelkastTemperaturen = {};
      });
    }
  }

  Future<void> _saveCheckedTasks() async {
    
    final Map<String, Map<String, dynamic>> terugkoel = {};
    for (final task in haccpTasks) {
      if (task.type == 'terugkoelen' || task.type == 'overig') {
        terugkoel[task.id] = {
          if (tempStartTimes[task.id] != null)
            'starttijd': tempStartTimes[task.id]!.toIso8601String(),
          if (tempStart[task.id] != null)
            'start': tempStart[task.id],
          if (temp2h[task.id] != null)
            '2u': temp2h[task.id],
          if (temp5h[task.id] != null)
            '5u': temp5h[task.id],
        };
      }
    }
    await FirebaseFirestore.instance
        .collection('haccp_checklists')
        .doc(dateString)
        .set({
          'tasks': checkedTasks,
          'medewerker': geselecteerdeMedewerker,
          'terugkoel': terugkoel,
          'closed': closed,
          'completionTimes': taskCompletionTimes.map((k, v) => MapEntry(k, v?.toIso8601String())),
          'terugkoelNamen': terugkoelNamen,
          'koelkastTemperaturen': koelkastTemperaturen,
        }, SetOptions(merge: true));
  }

  bool _isTempCheckComplete(String taskId) {
    
    return (tempStartTimes[taskId] != null) &&
        (tempStart[taskId]?.isNotEmpty ?? false) &&
        (temp2h[taskId]?.isNotEmpty ?? false) &&
        (temp5h[taskId]?.isNotEmpty ?? false);
  }

  bool _isTaskCompleted(HaccpTask task) {
    final checked = checkedTasks[task.id] ?? false;
    if (task.type == 'terugkoelen' || task.type == 'overig') {
      return checked && _isTempCheckComplete(task.id);
    }
    return checked;
  }

  void _onTaskChecked(String taskId, bool? value) {
    final task = haccpTasks.firstWhere((t) => t.id == taskId);

    // For terugkoelen: require naam
    if (task.type == 'terugkoelen' && value == true) {
      Set<String> missing = {};
      if ((terugkoelNamen[taskId]?.trim().isEmpty ?? true)) missing.add('naam');
      if (tempStartTimes[taskId] == null) missing.add('starttijd');
      if ((tempStart[taskId]?.isEmpty ?? true)) missing.add('start');
      if ((temp2h[taskId]?.isEmpty ?? true)) missing.add('2u');
      if ((temp5h[taskId]?.isEmpty ?? true)) missing.add('5u');
      if (missing.isNotEmpty) {
        setState(() {
          missingFields[taskId] = missing;
        });
        return;
      }
    }

    // For koelkast_temp: require temperature
    if (task.type == 'koelkast_temp' && value == true) {
      Set<String> missing = {};
      if ((koelkastTemperaturen[taskId]?.trim().isEmpty ?? true)) missing.add('temperatuur');
      if (missing.isNotEmpty) {
        setState(() {
          missingFields[taskId] = missing;
        });
        return;
      }
    }

    // For overig: keep your existing logic
    if (task.type == 'overig' && value == true) {
      Set<String> missing = {};
      if (tempStartTimes[taskId] == null) missing.add('starttijd');
      if ((tempStart[taskId]?.isEmpty ?? true)) missing.add('start');
      if ((temp2h[taskId]?.isEmpty ?? true)) missing.add('2u');
      if ((temp5h[taskId]?.isEmpty ?? true)) missing.add('5u');
      if (missing.isNotEmpty) {
        setState(() {
          missingFields[taskId] = missing;
        });
        return;
      }
    }

    setState(() {
      checkedTasks[taskId] = value ?? false;
      missingFields.remove(taskId);
      if (value == true) {
        taskCompletionTimes[taskId] = DateTime.now();
      } else {
        taskCompletionTimes.remove(taskId);
      }
    });
    _saveCheckedTasks();
  }

  void _onMedewerkerChanged(String? value) {
    if (value == null) return;
    setState(() {
      geselecteerdeMedewerker = value;
    });
    _saveCheckedTasks();
  }

  void _onTempFieldChanged(String taskId, {DateTime? starttijd, String? start, String? t2u, String? t5u}) {
    setState(() {
      if (starttijd != null) tempStartTimes[taskId] = starttijd;
      if (start != null) tempStart[taskId] = start;
      if (t2u != null) temp2h[taskId] = t2u;
      if (t5u != null) temp5h[taskId] = t5u;
      
      final missing = missingFields[taskId];
      if (missing != null) {
        if (starttijd != null && missing.contains('starttijd')) missing.remove('starttijd');
        if (start != null && missing.contains('start') && start.isNotEmpty) missing.remove('start');
        if (t2u != null && missing.contains('2u') && t2u.isNotEmpty) missing.remove('2u');
        if (t5u != null && missing.contains('5u') && t5u.isNotEmpty) missing.remove('5u');
        if (missing.isEmpty) missingFields.remove(taskId);
      }
    });
    _saveCheckedTasks();
  }

  void _showTaskDetails(HaccpTask task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Type: ${task.type}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    Text(task.info, style: const TextStyle(fontSize: 16)),
                    if (task.type == 'terugkoelen' || task.type == 'overig')
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const Text('Temperatuurregistratie', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Starttijd: '),
                                Text(tempStartTimes[task.id]?.toString().substring(0, 16) ?? '-'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Start: ${tempStart[task.id] ?? ''} °C'),
                            Text('Na 2 uur: ${temp2h[task.id] ?? ''} °C'),
                            Text('Na 5 uur: ${temp5h[task.id] ?? ''} °C'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Sluiten',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkMissingPreviousDays() async {
    setState(() {
      loadingAlerts = true;
      alertDates = [];
    });
    final now = DateTime.now();
    final prevDates = [
      now.subtract(const Duration(days: 1)),
      now.subtract(const Duration(days: 2)),
    ];
    for (final date in prevDates) {
      final doc = await FirebaseFirestore.instance
          .collection('haccp_checklists')
          .doc(DateFormat('yyyy-MM-dd').format(date))
          .get();
      if (!doc.exists) {
        alertDates.add(date);
      } else {
        final data = doc.data()!;
        if (data['closed'] == true) continue;
        final tasks = Map<String, bool>.from(data['tasks'] ?? {});
        bool allDone = true;
        for (final task in haccpTasks) {
          if (task.type == 'terugkoelen' || task.type == 'overig') {
            final terugkoel = data['terugkoel']?[task.id] ?? {};
            final complete = (terugkoel['starttijd'] != null) &&
                (terugkoel['start']?.toString().isNotEmpty ?? false) &&
                (terugkoel['2u']?.toString().isNotEmpty ?? false) &&
                (terugkoel['5u']?.toString().isNotEmpty ?? false) &&
                (tasks[task.id] == true);
            if (!complete) {
              allDone = false;
              break;
            }
          } else {
            if (tasks[task.id] != true) {
              allDone = false;
              break;
            }
          }
        }
        if (!allDone) alertDates.add(date);
      }
    }
    setState(() {
      loadingAlerts = false;
    });
  }

  void _toggleClosed() async {
    setState(() {
      closed = !closed;
    });
    await _saveCheckedTasks();
    _checkMissingPreviousDays(); 
  }

  void _changeDay(int delta) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: delta));
    });
    _loadCheckedTasks();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingTasks) {
      return const Center(child: CircularProgressIndicator());
    }
    final int todayWeekday = selectedDate.weekday; 
    final List<HaccpTask> visibleTasks = haccpTasks.where((task) =>
      task.weeklyDay == null || task.weeklyDay == todayWeekday
    ).toList();

    
    final sortedTasks = [...visibleTasks];
    sortedTasks.sort((a, b) {
      final aDone = _isTaskCompleted(a);
      final bDone = _isTaskCompleted(b);
      if (aDone == bDone) return 0;
      return aDone ? 1 : -1;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('HACCP $dateString', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: "Vandaag",
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
              });
              _loadCheckedTasks();
            },
          ),
          IconButton(
             iconSize: 40,
            icon: const Icon(Icons.chevron_left),
            tooltip: "Vorige dag",
            onPressed: () => _changeDay(-1),
          ),
          SizedBox(width: 10,),
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.chevron_right),
            tooltip: "Volgende dag",
            onPressed: () => _changeDay(1),
          ),
        ],
      ),
      body: Column(
        children: [
          if (loadingAlerts)
            const SizedBox(height: 8)
          else if (alertDates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Let op! Niet alle taken zijn afgerond op: ${alertDates.map((d) => DateFormat('dd-MM-yyyy').format(d)).join(', ')}",
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  "Medewerker:",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: geselecteerdeMedewerker,
                    isExpanded: true,
                    items: widget.medewerkers
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m),
                            ))
                        .toList(),
                    onChanged: closed ? null : _onMedewerkerChanged,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(closed ? Icons.lock_open : Icons.lock),
                  label: Text(closed ? "Heropen" : "Gesloten"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: closed ? Colors.orange : Colors.red,
                  ),
                  onPressed: _toggleClosed,
                ),
              ],
            ),
          ),
          if (closed)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.orange[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: const [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Deze dag is gemarkeerd als gesloten. Geen registratie nodig.",
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: AbsorbPointer(
              absorbing: closed,
              child: ListView.builder(
                itemCount: sortedTasks.length,
                itemBuilder: (context, idx) {
                  final task = sortedTasks[idx];
                  final isTempCheck = task.type == 'terugkoelen' || task.type == 'overig';
                  final completed = _isTaskCompleted(task);
                  final missing = missingFields[task.id] ?? {};

                  return InkWell(
                    onTap: () => _showTaskDetails(task),
                    child: Card(
                      color: completed ? Colors.green[100] : null,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: checkedTasks[task.id] ?? false,
                                  onChanged: (val) => _onTaskChecked(task.id, val),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    task.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // --- KOELKAST TEMPERATUUR: show textfield in list ---
                                if (task.type == 'koelkast_temp') ...[
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "Temperatuur",
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: (missing.contains('temperatuur')) ? Colors.red : Colors.grey,
                                            width: (missing.contains('temperatuur')) ? 3 : 1,
                                          ),
                                        ),
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: (missing.contains('temperatuur')) ? Colors.red : Colors.grey,
                                            width: (missing.contains('temperatuur')) ? 3 : 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: (missing.contains('temperatuur')) ? Colors.red : Colors.blue,
                                            width: (missing.contains('temperatuur')) ? 3 : 2,
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      controller: TextEditingController(
                                        text: koelkastTemperaturen[task.id] ?? '',
                                      ),
                                      onTap: () async {
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) => _TemperatureInputDialog(
                                            initialValue: koelkastTemperaturen[task.id] ?? '',
                                            label: 'Temperatuur (°C)',
                                          ),
                                        );
                                        if (result != null) {
                                          setState(() {
                                            koelkastTemperaturen[task.id] = result;
                                            // Remove highlight if filled
                                            if (missingFields[task.id]?.contains('temperatuur') == true && result.trim().isNotEmpty) {
                                              missingFields[task.id]?.remove('temperatuur');
                                              if (missingFields[task.id]?.isEmpty ?? false) missingFields.remove(task.id);
                                            }
                                          });
                                          _saveCheckedTasks();
                                        }
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          koelkastTemperaturen[task.id] = val;
                                          // Remove highlight if filled
                                          if (missingFields[task.id]?.contains('temperatuur') == true && val.trim().isNotEmpty) {
                                            missingFields[task.id]?.remove('temperatuur');
                                            if (missingFields[task.id]?.isEmpty ?? false) missingFields.remove(task.id);
                                          }
                                        });
                                        _saveCheckedTasks();
                                      },
                                    ),
                                  ),
                                ],
                                // --- TERUGKOELEN: show naam textfield in list ---
                                if (task.type == 'terugkoelen') ...[
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 140,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: "Naam product",
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: (missing.contains('naam')) ? Colors.red : Colors.grey,
                                            width: (missing.contains('naam')) ? 3 : 1,
                                          ),
                                        ),
                                        isDense: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: (missing.contains('naam')) ? Colors.red : Colors.grey,
                                            width: (missing.contains('naam')) ? 3 : 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: (missing.contains('naam')) ? Colors.red : Colors.blue,
                                            width: (missing.contains('naam')) ? 3 : 2,
                                          ),
                                        ),
                                      ),
                                      controller: TextEditingController.fromValue(
                                        TextEditingValue(
                                          text: terugkoelNamen[task.id] ?? '',
                                          selection: TextSelection.collapsed(offset: (terugkoelNamen[task.id] ?? '').length),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          terugkoelNamen[task.id] = val;
                                          // Remove highlight if filled
                                          if (missingFields[task.id]?.contains('naam') == true && val.trim().isNotEmpty) {
                                            missingFields[task.id]?.remove('naam');
                                            if (missingFields[task.id]?.isEmpty ?? false) missingFields.remove(task.id);
                                          }
                                        });
                                        _saveCheckedTasks();
                                      },
                                    ),
                                  ),
                                ],

                                if (isTempCheck) ...[
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 110,
                                    child: InkWell(
                                      onTap: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: tempStartTimes[task.id] != null
                                              ? TimeOfDay.fromDateTime(tempStartTimes[task.id]!)
                                              : TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          final now = DateTime.now();
                                          final dt = DateTime(
                                            now.year,
                                            now.month,
                                            now.day,
                                            time.hour,
                                            time.minute,
                                          );
                                          _onTempFieldChanged(task.id, starttijd: dt);
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: "Starttijd",
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: missing.contains('starttijd') ? Colors.red : Colors.grey,
                                              width: missing.contains('starttijd') ? 3 : 1,
                                            ),
                                          ),
                                          isDense: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: missing.contains('starttijd') ? Colors.red : Colors.grey,
                                              width: missing.contains('starttijd') ? 3 : 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: missing.contains('starttijd') ? Colors.red : Colors.blue,
                                              width: missing.contains('starttijd') ? 3 : 2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          tempStartTimes[task.id]?.toString().substring(11, 16) ?? '--:--',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  SizedBox(
                                    width: 60,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) => _TemperatureInputDialog(
                                            initialValue: tempStart[task.id] ?? '',
                                            label: 'Start temperatuur (°C)',
                                          ),
                                        );
                                        if (result != null) {
                                          _onTempFieldChanged(task.id, start: result);
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: "Start",
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('start') ? Colors.red : Colors.grey,
                                                width: missing.contains('start') ? 3 : 1,
                                              ),
                                            ),
                                            isDense: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('start') ? Colors.red : Colors.grey,
                                                width: missing.contains('start') ? 3 : 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('start') ? Colors.red : Colors.blue,
                                                width: missing.contains('start') ? 3 : 2,
                                              ),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: TextEditingController(
                                            text: tempStart[task.id] ?? '',
                                          ),
                                          readOnly: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  SizedBox(
                                    width: 60,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) => _TemperatureInputDialog(
                                            initialValue: temp2h[task.id] ?? '',
                                            label: 'Temperatuur na 2 uur (°C)',
                                          ),
                                        );
                                        if (result != null) {
                                          _onTempFieldChanged(task.id, t2u: result);
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: "2u",
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('2u') ? Colors.red : Colors.grey,
                                                width: missing.contains('2u') ? 3 : 1,
                                              ),
                                            ),
                                            isDense: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('2u') ? Colors.red : Colors.grey,
                                                width: missing.contains('2u') ? 3 : 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('2u') ? Colors.red : Colors.blue,
                                                width: missing.contains('2u') ? 3 : 2,
                                              ),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: TextEditingController(
                                            text: temp2h[task.id] ?? '',
                                          ),
                                          readOnly: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  SizedBox(
                                    width: 60,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) => _TemperatureInputDialog(
                                            initialValue: temp5h[task.id] ?? '',
                                            label: 'Temperatuur na 5 uur (°C)',
                                          ),
                                        );
                                        if (result != null) {
                                          _onTempFieldChanged(task.id, t5u: result);
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: "5u",
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('5u') ? Colors.red : Colors.grey,
                                                width: missing.contains('5u') ? 3 : 1,
                                              ),
                                            ),
                                            isDense: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('5u') ? Colors.red : Colors.grey,
                                                width: missing.contains('5u') ? 3 : 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: missing.contains('5u') ? Colors.red : Colors.blue,
                                                width: missing.contains('5u') ? 3 : 2,
                                              ),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: TextEditingController(
                                            text: temp5h[task.id] ?? '',
                                          ),
                                          readOnly: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            
                            Text(
                              task.info,
                              maxLines: widget.maxlines,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemperatureInputDialog extends StatefulWidget {
  final String initialValue;
  final String label;
  const _TemperatureInputDialog({required this.initialValue, required this.label});

  @override
  State<_TemperatureInputDialog> createState() => _TemperatureInputDialogState();
}

class _TemperatureInputDialogState extends State<_TemperatureInputDialog> {
  String? sign; // '+' or '-'
  String value = '';

  @override
  void initState() {
    super.initState();
    String initial = widget.initialValue.replaceAll(',', '.').trim();
    if (initial.startsWith('-')) {
      sign = '-';
      value = initial.substring(1);
    } else if (initial.startsWith('+')) {
      sign = '+';
      value = initial.substring(1);
    } else if (initial.isNotEmpty) {
      sign = '+';
      value = initial;
    }
  }

  void _onSignPress(String s) {
    setState(() {
      sign = s;
      value = ''; // Always reset value when sign is pressed
    });
  }

  void _onNumpadPress(String char) {
    if (sign == null) return; // Require sign first
    setState(() {
      if (char == '.') {
        if (!value.contains('.')) {
          value = value.isEmpty ? '0.' : '$value.';
        }
      } else if (char == 'back') {
        if (value.isNotEmpty) value = value.substring(0, value.length - 1);
      } else {
        // Only allow one decimal
        if (value.contains('.') && value.split('.').last.length >= 1) return;
        value += char;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayValue = (sign ?? '?') + (value.isEmpty ? '0.0' : value);

    return AlertDialog(
      title: Text(widget.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _SignButton(
                label: '+',
                selected: sign == '+',
                enabled: true, // <-- always enabled
                onTap: () => _onSignPress('+'),
              ),
              const SizedBox(width: 8),
              _SignButton(
                label: '-',
                selected: sign == '-',
                enabled: true, // <-- always enabled
                onTap: () => _onSignPress('-'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    displayValue,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Numpad(
            onPressed: (char) => _onNumpadPress(char),
            onBackspace: () => _onNumpadPress('back'),
            enabled: sign != null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          onPressed: sign == null
              ? null
              : () {
                  String result = (sign ?? '+') + (value.isEmpty ? '0.0' : value);
                  double? d = double.tryParse(result.replaceAll(',', '.'));
                  Navigator.of(context).pop(d != null ? d.toStringAsFixed(1) : '0.0');
                },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _SignButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  const _SignButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? (label == '+' ? Colors.green[200] : Colors.red[200]) : Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final void Function(String) onPressed;
  final VoidCallback onBackspace;
  final bool enabled;
  const _Numpad({required this.onPressed, required this.onBackspace, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Column(
          children: [
            Row(
              children: [
                _NumpadButton('1', onPressed),
                _NumpadButton('2', onPressed),
                _NumpadButton('3', onPressed),
              ],
            ),
            Row(
              children: [
                _NumpadButton('4', onPressed),
                _NumpadButton('5', onPressed),
                _NumpadButton('6', onPressed),
              ],
            ),
            Row(
              children: [
                _NumpadButton('7', onPressed),
                _NumpadButton('8', onPressed),
                _NumpadButton('9', onPressed),
              ],
            ),
            Row(
              children: [
                _NumpadButton('.', onPressed),
                _NumpadButton('0', onPressed),
                _NumpadButton(
                  Icons.backspace,
                  (_) => onBackspace(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final dynamic label; // String or IconData
  final void Function(String) onPressed;
  const _NumpadButton(this.label, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              if (label is String) {
                onPressed(label as String);
              } else if (label is IconData) {
                onPressed('back');
              }
            },
            child: SizedBox(
              height: 48,
              child: Center(
                child: label is String
                    ? Text(label as String, style: const TextStyle(fontSize: 22))
                    : Icon(label as IconData, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}