class Donation {
  int? id;
  int? petId;
  int? userId;
  String? type;            // Food | Medical | Money
  double? amount;          // nullable, for Money donations
  String? description;     // nullable, for non-Money donations
  int? status;             // 0 = pending, 1 = achieved, etc.

  Donation({
    this.id,
    this.petId,
    this.userId,
    this.type,
    this.amount,
    this.description,
    this.status,
  });

  Donation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    petId = json['pet_id'];
    userId = json['user_id'];
    type = json['type'];
    amount = json['amount'] != null ? double.tryParse(json['amount'].toString()) : null;
    description = json['description'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['type'] = type;
    data['amount'] = amount;
    data['description'] = description;
    data['status'] = status;
    return data;
  }
}
