import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInterestScreen extends StatefulWidget {
  @override
  _UserInterestScreenState createState() => _UserInterestScreenState();
}

class _UserInterestScreenState extends State<UserInterestScreen> {
  late String userId;
  late String selectedInterestId = ''; // Inicialización de selectedInterestId

  TextEditingController userIdController = TextEditingController();
  List<Map<String, dynamic>> interests = []; // Lista de intereses

  @override
  void initState() {
    super.initState();
    userIdController.text = '';

    // Obtener lista de intereses al iniciar
    fetchInterests().then((value) {
      setState(() {
        interests = value;
        if (interests.isNotEmpty) {
          selectedInterestId = interests[0]['id'].toString();
        }
      });
    });
  }

  // Método para obtener la lista de intereses
  Future<List<Map<String, dynamic>>> fetchInterests() async {
    final response =
        await http.get(Uri.parse('https://guerrero.terrabyteco.com/api/Interest'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load interests');
    }
  }

  Future<void> updateUserInterest() async {
    String userId = userIdController.text;

    final response = await http.post(
      Uri.parse('https://guerrero.terrabyteco.com/api/UserInterest/$userId/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'interest_id': selectedInterestId, // Utiliza selectedInterestId
      }),
    );

    if (response.statusCode == 200) {
      print('Interés de usuario actualizado correctamente');
    } else {
      print('Error al actualizar el interés del usuario');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interés del Usuario'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userIdController,
                decoration: InputDecoration(labelText: 'ID de Usuario'),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedInterestId, // Valor seleccionado
                onChanged: (String? newValue) {
                  setState(() {
                    selectedInterestId = newValue!;
                  });
                },
                items: interests.map((interest) {
                  return DropdownMenuItem<String>(
                    value: interest['id'].toString(),
                    child: Text(interest['Nombre']), // Muestra el nombre del interés
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUserInterest,
                child: Text('Actualizar Interés'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserInterestScreen(),
  ));
}
