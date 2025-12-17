class UserModel {
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String? imagePath;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'imagePath': imagePath,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      birthDate: json['birthDate'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }
}
