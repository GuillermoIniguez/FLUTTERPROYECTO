import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SelectInterestScreen extends StatelessWidget {
  final List<Interest> interests;

  const SelectInterestScreen({Key? key, required this.interests}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Interés'),
      ),
      body: ListView.builder(
        itemCount: interests.length,
        itemBuilder: (context, index) {
          final interest = interests[index];
          return ListTile(
            title: Text(interest.nombre),
            subtitle: Text(interest.categoria),
            onTap: () {
              // Aquí puedes agregar la lógica para actualizar el interés del usuario en el servidor
              // Por ahora, simplemente imprimimos el nombre del interés seleccionado
              print('Interés seleccionado: ${interest.nombre}');
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
