import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'third_screen.dart';

class SecondScreen extends StatelessWidget {
  Future<Map<String, dynamic>> fetchRandomUser() async {
    final response = await http.get(Uri.parse('https://randomuser.me/api/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['results'][0];
    } else {
      throw Exception('Failed to load user information');
    }
  }

  Future<void> saveUserToDatabase(Map<String, dynamic> userData) async {
    final Database db = await openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, age INTEGER, email TEXT)',
        );
      },
      version: 1,
    );

    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              Map<String, dynamic> userData = await fetchRandomUser();
              await saveUserToDatabase(userData);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThirdScreen()),
              );
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text('Fetch User Info and Save to Database'),
        ),
      ),
    );
  }
}
