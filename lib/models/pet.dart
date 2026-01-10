class Pet {
  int? petId;
  int? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  List<String>? imagePaths;
  double? lat;
  double? lng;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.imagePaths,
    this.lat,
    this.lng,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    if (json['image_paths'] != null) {
      if (json['image_paths'] is List) {
        imagePaths = List<String>.from(json['image_paths']);
      } else if (json['image_paths'] is String) {
        imagePaths = (json['image_paths'] as String).split(',');
      }
    }
    lat = double.tryParse(json['lat'].toString());
    lng = double.tryParse(json['lng'].toString());
  }
}