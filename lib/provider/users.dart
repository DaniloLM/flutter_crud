import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_crud/models/user.dart';
import 'package:http/http.dart' as http;

class Users with ChangeNotifier {
  static const _baseUrl = 'https://flutter-crud-69c02.firebaseio.com/';
  final Map<String, User> _items = {};

  Future<void> fetchUsers() async {
    final response = await http.get('$_baseUrl/users.json');
    Map<String, dynamic> data = json.decode(response.body);

    data.forEach((key, value) {
      _items.putIfAbsent(
        key,
        () => User(
          id: key,
          name: value['name'],
          email: value['email'],
          avatarUrl: value['avatarUrl'],
        ),
      );
    });
    notifyListeners();
  }

  List<User> get all { 
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  Future<void> put(User user) async {
    if (user == null) {
      return;
    }

    if (user.id != null &&
        user.id.trim().isNotEmpty &&
        _items.containsKey(user.id)) {
      await http.patch(
        "$_baseUrl/users/${user.id}.json",
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarUrl': user.avatarUrl,
        }),
      );

      _items.update(
        user.id,
        (value) => User(
          id: user.id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    } else {
      final response = await http.post(
        "$_baseUrl/users.json",
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'avatarUrl': user.avatarUrl,
        }),
      );

      final id = json.decode(response.body)['name'];

      _items.putIfAbsent(
        id,
        () => User(
          id: id,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        ),
      );
    }
    notifyListeners();
  }

  void remove(User user) async {
    if (user != null && user.id != null) {
      await http.delete("$_baseUrl/users/${user.id}.json");
      _items.remove(user.id);
      notifyListeners();
    }
  }
}
