class User {
  String? userId;
  String? userEmail;
  String? userName;
  String? userPhone;
  String? userRegDate;
  String? profileImagePath;

  User(
      {this.userId,
      this.userEmail,
      this.userName,
      this.userPhone,
      this.userRegDate,
      this.profileImagePath});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    userEmail = json['email'];
    userName = json['name'];
    userPhone = json['phone'];
    userRegDate = json['reg_date'];
    profileImagePath = json['profile_image_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['email'] = userEmail;
    data['name'] = userName;
    data['phone'] = userPhone;
    data['reg_date'] = userRegDate;
    data['profile_image_path'] = profileImagePath;
    return data;
  }
}