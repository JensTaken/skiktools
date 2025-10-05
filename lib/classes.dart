class HaccpTask {
  final String id;
  final String name;
  final String type;
  final String info;
  final int? weeklyDay; 

  HaccpTask({
    required this.id,
    required this.name,
    required this.type,
    required this.info,
    this.weeklyDay,
  });
}
