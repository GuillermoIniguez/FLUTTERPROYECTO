import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<dynamic> matches = [];
  late int loggedInUserId; 

  @override
  void initState() {
    super.initState();
    getUserID(); 
  }

  Future<void> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedInUserId = prefs.getInt('user_id') ?? 0; 
    fetchMatches(); 
  }

  Future<void> fetchMatches() async {
    
    
    final response = await http.get(Uri.parse('https://guerrero.terrabyteco.com/api/Matches/user/$loggedInUserId'));

    if (response.statusCode == 200) {
      setState(() {
        matches = json.decode(response.body)['matches'];
      });
    } else {
      
      print('Failed to load matches');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matches'),
      ),
      body: matches.isEmpty
          ? Center(
              child: Text(
                'No tienes matches aún 😊',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                
                String userName1 = matches[index]['user1']['name'];
                String userName2 = matches[index]['user2']['name'];

              
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Match con $userName2',
                      style: TextStyle(fontSize: 18),
                    ),
                    
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        
                        deleteMatch(matches[index]['id']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  
  Future<void> deleteMatch(int matchId) async {
    final response = await http.delete(
      Uri.parse('https://guerrero.terrabyteco.com/api/Matches/$matchId/delete'),
    );
    if (response.statusCode == 200) {
      
      fetchMatches();
   
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match eliminado correctamente'),
        ),
      );
    } else {
      
      print('Failed to delete match');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el match'),
        ),
      );
    }
  }
}
