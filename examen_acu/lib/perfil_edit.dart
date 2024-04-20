import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_list.dart';

class PerfilEdit extends StatefulWidget {
  @override
  _PerfilEditState createState() => _PerfilEditState();
}

class _PerfilEditState extends State<PerfilEdit> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _surnameController;
  late int _levelId = 0;
  bool _isLoading = true;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _surnameController = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfile = jsonDecode(prefs.getString('user_profile') ?? '{}');
    _nameController.text = userProfile['name'] ?? '';
    _emailController.text = userProfile['email'] ?? '';
    _phoneController.text = userProfile['phone'] ?? '';
    _surnameController.text = userProfile['surname'] ?? '';
    _levelId = userProfile['level_id'] ?? 0;
    _accessToken = prefs.getString('access_token');
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final updateData = {
      'id': userId,
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'level_id': _levelId,
      'surname': _surnameController.text,
    };

    final response = await http.post(
      Uri.parse('https://guerrero.terrabyteco.com/api/User/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
      // Actualizar los datos del perfil en SharedPreferences
      _updateProfileData(updateData);
      // Redirigir a la página del perfil
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el perfil'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateProfileData(Map<String, dynamic> updatedData) async {
    final prefs = await SharedPreferences.getInstance();
    final userProfile = jsonDecode(prefs.getString('user_profile') ?? '{}');
    userProfile['name'] = updatedData['name'];
    userProfile['email'] = updatedData['email'];
    userProfile['phone'] = updatedData['phone'];
    userProfile['surname'] = updatedData['surname'];
    prefs.setString('user_profile', jsonEncode(userProfile));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Correo electrónico'),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Teléfono'),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(labelText: 'Apellido'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: updateUserProfile,
                    child: Text('Guardar cambios'),
                  ),
                  SizedBox(height: 16.0),
                  Text('Token de acceso: $_accessToken'),
                ],
              ),
            ),
    );
  }
}
