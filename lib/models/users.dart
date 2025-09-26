class User {
  final int id;
  final String nip;
  final String email;
  final String password;
  final String firstname;
  // final String lastname;
  final String name;
  final String jabatan;
  final String alamat;
  final String imageUrl;

  User({
    required this.id,
    required this.nip,
    required this.email,
    required this.password,
    required this.firstname,
    // required this.lastname,
    required this.name,
    required this.jabatan,
    required this.alamat,
    required this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0, 
      nip: json['NIP'].toString(),
      email: json['email'],
      password: json['password'],
      firstname: json['nama_depan'],
      // lastname: json['nama_belakang'],
      name: json['Nama'],
      jabatan: json['Jabatan'],
      alamat: json['Alamat'],
      imageUrl: json['image'],
    );
  }
}
