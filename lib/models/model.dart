class PersonModel {
  final int id;
  final String name;
  final String? address;
  final String? imagePath; // ADD THIS

  const PersonModel({
    required this.id,
    required this.name,
    this.address,
    this.imagePath, // ADD THIS
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'imagePath': imagePath, // ADD THIS
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      imagePath: map['imagePath'], // ADD THIS
    );
  }
}

class Commit2 {}
