import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:aplikasi_absensi/models/users.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nipController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _firstNameController;
  late TextEditingController _namaController;
  late TextEditingController _positionController;
  late TextEditingController _addressController;

  File? _profilePicture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nipController = TextEditingController(text: widget.user.nip);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController(text: widget.user.password);
    _firstNameController = TextEditingController(text: widget.user.firstname);
    _namaController = TextEditingController(text: widget.user.name);
    // _lastNameController = TextEditingController(text: widget.user.lastname);
    _positionController = TextEditingController(text: widget.user.jabatan);
    _addressController = TextEditingController(text: widget.user.alamat);
  }

  @override
  void dispose() {
    _nipController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _namaController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = int.tryParse(prefs.getString('id') ?? '');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mendapatkan ID pengguna')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost/API_CRUD/edit_profile.php?'),
    );
    request.fields['id'] = userId.toString(); // Kirim ID dalam fields
    request.fields['nip'] = _nipController.text;
    request.fields['email'] = _emailController.text;
    request.fields['nama_depan'] = _firstNameController.text;
    request.fields['nama'] = _namaController.text;
    request.fields['jabatan'] = _positionController.text;
    request.fields['alamat'] = _addressController.text;

    if (_passwordController.text.isNotEmpty) {
      request.fields['password'] = _passwordController.text;
    }

    // Handle gambar untuk Flutter Mobile vs Web/Desktop
    if (_profilePicture != null) {
      if (kIsWeb) {
        // FLUTTER WEB: Gunakan `fromBytes`
        Uint8List bytes = await _profilePicture!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_picture',
            bytes,
            filename: path.basename(_profilePicture!.path),
          ),
        );
      } else {
        // FLUTTER MOBILE (Android/iOS): Gunakan `fromPath`
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture',
            _profilePicture!.path,
          ),
        );
      }
    }

    var response = await request.send();
    var responseBody =
        await response.stream.bytesToString(); // Convert stream ke String
    // debugPrint("Response Body: $responseBody"); // Debugging

    try {
      var responseData = jsonDecode(responseBody);

      if (response.statusCode == 200 && responseData['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? 'Gagal memperbarui profil.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Terjadi kesalahan dalam memproses data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Hilangkan shadow bawaan
        title: Text(
          'Edit Profile',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            height: 1,
            color: Colors.grey[300], // Warna divider lebih halus
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: _profilePicture != null
                        ? Image.file(
                            _profilePicture!,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        // ignore: unnecessary_null_comparison
                        : widget.user.imageUrl != null
                            ? Image.network(
                                widget.user.imageUrl,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/schedule.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/placeholder.png',
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 28),
                      onPressed: () => _showImagePicker(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _nipController,
              decoration: InputDecoration(
                labelText: 'NIP',
                prefixIcon: const Icon(Icons.badge),
                focusColor: Colors.blue,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                focusColor: Colors.blue,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                focusColor: Colors.blue,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'Nama Depan',
                prefixIcon: const Icon(Icons.person),
                focusColor: Colors.blue,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: const Icon(Icons.person_outline),
                focusColor: Colors.blue,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _positionController,
              decoration: InputDecoration(
                labelText: 'Jabatan',
                prefixIcon: const Icon(Icons.work),
                focusColor: Colors.blue,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Alamat',
                prefixIcon: const Icon(Icons.location_on),
                focusColor: Colors.blue,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Ambil Foto dari Kamera'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri'),
            onTap: () async {
              Navigator.pop(context);
              await _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
