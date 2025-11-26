class BillItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final Map<String, int> consumedBy; // userId -> quantity consumed

  BillItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    Map<String, int>? consumedBy,
  }) : consumedBy = consumedBy ?? {};

  double get totalPrice => price * quantity;

  BillItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    Map<String, int>? consumedBy,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      consumedBy: consumedBy ?? Map.from(this.consumedBy),
    );
  }
}
