import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateInterest extends StatefulWidget {
  @override
  _CreateInterestState createState() => _CreateInterestState();
}

class _CreateInterestState extends State<CreateInterest> {
  TextEditingController _interestController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  Future<void> saveInterest(String name, String category) async {
    final response = await http.post(
      Uri.parse('https://guerrero.terrabyteco.com/api/Interest/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      // Mostrar un mensaje emergente de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Interés creado correctamente!'),
        ),
      );
    } else {
      // Manejar el caso en que falle la solicitud
      print('Failed to save interest');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Interés'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingrese el nombre del interés:',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _interestController,
              decoration: InputDecoration(
                hintText: 'Nombre del interés',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0), // Espaciado adicional entre los campos de entrada
            Text(
              'Ingrese la categoría:',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                hintText: 'Categoría',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String interestName = _interestController.text.trim();
                String category = _categoryController.text.trim();
                saveInterest(interestName, category);
              },
              child: Text('Guardar Interés'),
            ),
          ],
        ),
      ),
    );
  }
}
