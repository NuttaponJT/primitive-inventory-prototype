final tableCatelog = 'catelog';

class CatelogFields {
  
  static final List<String> values = [
    id, 
    categ_name, 
  ];

  static final String id = '_id';
  static final String categ_name = 'categ_name';
}

class Catelog {
  final int? id;
  final String categ_name;

  const Catelog({
    this.id, 
    required this.categ_name, 
  });

  Catelog copy({
    int? id, 
    String? categ_name, 
  }) =>
    Catelog(
      id: id ?? this.id, 
      categ_name: categ_name ?? this.categ_name, 
    );

  static Catelog fromJson(Map<String, Object?> json) => Catelog(
    id: json[CatelogFields.id] as int?, 
    categ_name: json[CatelogFields.categ_name] as String, 
  );

  Map<String, Object?> toJson() => {
    CatelogFields.id: id, 
    CatelogFields.categ_name: categ_name, 
  };
}