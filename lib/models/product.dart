// class Product {
//   final int id;
//   final String title;
//   final double price;
//   final String description;
//   final String image;
//   bool isFavorite;

//   Product({
//     required this.id,
//     required this.title,
//     required this.price,
//     required this.description,
//     required this.image,
//     this.isFavorite = false,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       title: json['title'],
//       price: double.parse(json['price'].toString()),
//       description: json['description'],
//       image: json['image'],
//     );
//   }
// }

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: double.parse(json['price'].toString()),
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'image': image,
      'isFavorite': isFavorite,
    };
  }
}
