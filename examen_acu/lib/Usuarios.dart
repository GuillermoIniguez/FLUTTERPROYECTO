import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Usuarios extends StatefulWidget {
  @override
  _UsuariosState createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  List<dynamic> users = [];
  late int loggedUserId;

  @override
  void initState() {
    super.initState();
    _getUserID();
    fetchUsers();
  }

  Future<void> _getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedUserId = prefs.getInt('user_id') ?? 0;
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://guerrero.terrabyteco.com/api/User/'));

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('https://guerrero.terrabyteco.com/api/User/$userId'));

    if (response.statusCode == 200) {
      
      fetchUsers();
    } else {
      throw Exception('Failed to delete user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuarios'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          
          if (users[index]['id'] == loggedUserId) {
            return Container(); 
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                users[index]['Imagen'] ?? 'https://via.placeholder.com/150',
              ),
            ),
            title: Text(
              '${users[index]['Nombre'] ?? 'Nombre Desconocido'} ${users[index]['Apellido'] ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${users[index]['Email'] ?? 'Email Desconocido'}',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Eliminar Usuario'),
                      content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancelar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Eliminar'),
                          onPressed: () {
                            
                            deleteUser(users[index]['id']);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
