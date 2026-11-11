class CartItem {
  final int mealId;
  final String name;
  final int price;
  final String imageUrl;
  final String restaurantName;
  final String city;
  final String distributionLocation;

  int quantity;

  CartItem({
    required this.mealId,
    required this.name,
    required this.price,
    String imageUrl = '',
    this.restaurantName = '',
    this.city = '',
    this.distributionLocation = '',
    this.quantity = 1,
  }) : imageUrl = imageUrl;

  int get total => price * quantity;
}

class CartData {
  static final List<CartItem> items = [];

  static void addOrUpdate(CartItem newItem) {
    final index = items.indexWhere(
      (item) => item.mealId == newItem.mealId,
    );

    if (index >= 0) {
      items[index].quantity += newItem.quantity;
    } else {
      items.add(newItem);
    }
  }

  static void remove(int index) {
    items.removeAt(index);
  }

  static void setQuantity(int index, int quantity) {
    if (index >= 0 && index < items.length && quantity > 0) {
      items[index].quantity = quantity;
    }
  }

  static int get grandTotal {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  static void clear() {
    items.clear();
  }
}