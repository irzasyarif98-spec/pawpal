class Adoption {
  int? adoptionId;
  int? petId;
  int? adopterId;
  int? ownerUserId;
  String? message;
  String? status;

  Adoption(
      {this.adoptionId,
      this.petId,
      this.adopterId,
      this.ownerUserId,
      this.message,
      this.status});

  Adoption.fromJson(Map<String, dynamic> json) {
    adoptionId = json['id'];
    petId = json['pet_id'];
    adopterId = json['user_id'];
    ownerUserId = json['owner_user_id'];
    message = json['message'];
    if (json['approved'] == null) {
      status = 'pending';
    } else if (json['approved'].toString() == '0') {
      status = 'rejected';
    } else if (json['approved'].toString() == '1') {
      status = 'approved';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adoption_id'] = adoptionId;
    data['pet_id'] = petId;
    data['adopter_id'] = adopterId;
    data['owner_id'] = ownerUserId;
    data['message'] = message;
    if (status == 'pending') {
      data['approved'] = null;
    } else if (status == 'rejected') {
      data['approved'] = 0;
    } else if (status == 'approved') {
      data['approved'] = 1;
    }
    return data;
  }
}
