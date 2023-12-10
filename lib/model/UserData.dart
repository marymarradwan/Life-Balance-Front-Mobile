class UserData {
  final String email;
  final String id;
  final String name;
  final PictureUser pictureUser;
  const UserData({this.email, this.name, this.id, this.pictureUser});
  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
      email: json["email"],
      id: json["id"] as String,
      name: json["name"],
      pictureUser: PictureUser.fromJson(json["picture"]["data"]));

  @override
  String toString() {
    return "email : $email , id: $id , name:$name  picture : $pictureUser";
  }
}

class PictureUser {
  final String imageUrl;

  const PictureUser({this.imageUrl});
  factory PictureUser.fromJson(Map<String, dynamic> json) => PictureUser(
        imageUrl: json['url'],
      );

  @override
  String toString() {
    return "imageUrl : $imageUrl";
  }
}
