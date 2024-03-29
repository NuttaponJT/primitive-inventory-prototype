final String tableInventoryLine = 'inventory_line';

class InventoryLineFields {

  static final List<String> values = [
    id
    , item_name
    , item_desc
    , in_stock
    , image_path
    , categ_id
  ];

  static final String id = '_id';
  static final String item_name = 'item_name';
  static final String item_desc = 'item_desc';
  static final String in_stock = 'in_stock';
  static final String image_path = 'image_path';
  static final String categ_id = 'categ_id';
}

class InventoryLine {
  final int? id;
  final String item_name;
  final String item_desc;
  final int in_stock;
  final String image_path;
  final int categ_id;

  const InventoryLine({
    this.id
    , required this.item_name
    , required this.item_desc
    , required this.in_stock
    , required this.image_path
    , required this.categ_id
  });

  InventoryLine copy({
    int? id
    , String? item_name
    , String? item_desc
    , int? in_stock
    , String? image_path
    , int? categ_id
  }) =>
      InventoryLine(
        id: id ?? this.id
        , item_name: item_name ?? this.item_name
        , item_desc: item_desc ?? this.item_desc
        , in_stock: in_stock ?? this.in_stock
        , image_path: image_path ?? this.image_path
        , categ_id: categ_id ?? this.categ_id
      );

  static InventoryLine fromJson(Map<String, Object?> json) => InventoryLine(
        id: json[InventoryLineFields.id] as int?
        , item_name: json[InventoryLineFields.item_name] as String
        , item_desc: json[InventoryLineFields.item_desc] as String
        , in_stock: json[InventoryLineFields.in_stock] as int
        , image_path: json[InventoryLineFields.image_path] as String
        , categ_id: json[InventoryLineFields.categ_id] as int
      );

  Map<String, Object?> toJson() => {
        InventoryLineFields.id: id
        , InventoryLineFields.item_name: item_name
        , InventoryLineFields.item_desc: item_desc
        , InventoryLineFields.in_stock: in_stock
        , InventoryLineFields.image_path: image_path
        , InventoryLineFields.categ_id: categ_id
      };
      
}
