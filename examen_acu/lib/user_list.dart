import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'matches_screen.dart';
import 'UserInterestScreen.dart';
import 'Usuarios.dart'; 
import 'create_interest.dart'; 
import 'perfil_edit.dart'; 
import 'package:cached_network_image/cached_network_image.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<dynamic> users = [];
  late int loggedInUserId;
  int? userLevelId; 
  late SharedPreferences prefs;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    initializePreferences();
    fetchUsers();
    _searchController = TextEditingController();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://guerrero.terrabyteco.com/api/User'));

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    getUserID();
    getUserLevel(); // Llama a getUserLevel() aquí para asegurarte de que se complete antes de acceder a userLevelId
  }

  Future<void> getUserID() async {
    final userProfile = jsonDecode(prefs.getString('user_profile') ?? '{}');
    loggedInUserId = userProfile['id'];
  }

  Future<void> getUserLevel() async {
    final userProfile = jsonDecode(prefs.getString('user_profile') ?? '{}');
    userLevelId = userProfile['level_id'];
  }

  Future<String> fetchUserInterest(int userId) async {
    final response = await http.get(Uri.parse('https://guerrero.terrabyteco.com/api/UserInterest/?user_id=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> userInterests = json.decode(response.body);
      if (userInterests.isNotEmpty) {
        final userInterest = userInterests.firstWhere(
          (interest) => interest['user_id'] != null && interest['user_id']['id'] == userId,
          orElse: () => null,
        );
        if (userInterest != null && userInterest['interest_id'] != null) {
          return userInterest['interest_id']['name'] ?? 'sin interes';
        } else {
          return 'sin interes';
        }
      } else {
        return 'sin interes';
      }
    } else {
      throw Exception('Failed to load user interest');
    }
  }

  Future<void> makeMatch(int otherUserId) async {
    final response = await http.post(
      Uri.parse('https://guerrero.terrabyteco.com/api/Matches/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'user_id1': loggedInUserId, 'user_id2': otherUserId}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final matchId = responseData['match_id'];
      final matchedUserName = responseData['matched_user_name'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Match creado con $matchedUserName!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Failed to make match');
    }
  }

  Future<void> _logout() async {
    await prefs.clear(); 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _filterUsers(String keyword) {
    setState(() {
      users = users.where((user) {
        final fullName = '${user['Nombre'] ?? 'Nombre Desconocido'} ${user['Apellido'] ?? ''}'.toLowerCase();
        return fullName.contains(keyword.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuarios'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MatchesScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInterestScreen()),
              );
            },
          ),
          
          if (userLevelId != null && userLevelId != 1)
          IconButton(
            icon: Icon(Icons.group), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Usuarios()), 
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: UserSearch(users));
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Cerrar Sesión'),
              onTap: _logout,
            ),
           
            if (userLevelId != null && userLevelId != 1) 
            ListTile(
              title: Text('Crear Interés'),
              leading: Icon(Icons.create),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateInterest()),
                );
              },
            ),
            ListTile(
              title: Text('Perfil'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerfilEdit()), 
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          
          if (users[index]['id'] == loggedInUserId) {
            return SizedBox.shrink(); 
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      users[index]['Imagen'] ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                  title: Text(
                    '${users[index]['Nombre'] ?? 'Nombre Desconocido'} ${users[index]['Apellido'] ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: FutureBuilder<String>(
                    future: fetchUserInterest(users[index]['id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          'Cargando...',
                          style: TextStyle(color: Colors.grey),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error al cargar el interés',
                          style: TextStyle(color: Colors.red),
                        );
                      } else {
                        return Text(
                          snapshot.data ?? '',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                    },
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      makeMatch(users[index]['id']);
                    },
                    child: Text('Match'),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class UserSearch extends SearchDelegate<String> {
  final List<dynamic> users;

  UserSearch(this.users);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = users.where((user) {
      final fullName = '${user['Nombre'] ?? 'Nombre Desconocido'} ${user['Apellido'] ?? ''}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${results[index]['Nombre']} ${results[index]['Apellido'] ?? ''}'),
          onTap: () {
            close(context, results[index]['Nombre']);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = users.where((user) {
      final fullName = '${user['Nombre'] ?? 'Nombre Desconocido'} ${user['Apellido'] ?? ''}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${results[index]['Nombre']} ${results[index]['Apellido'] ?? ''}'),
          onTap: () {
            query = '${results[index]['Nombre']}';
            showResults(context);
          },
        );
      },
    );
  }
}
