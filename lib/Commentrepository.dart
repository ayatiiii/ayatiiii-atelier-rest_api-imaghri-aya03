import 'package:rest_api/models/comment.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Commentrepository {
  Future<List<Comment>> fetchComments() async {
    final response = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/comments"));
    if (response.statusCode == 200) {
      List<dynamic> jsonComments = json.decode(response.body);
      List<Comment> comments =
      jsonComments.map((json) => Comment.fromJson(json)).toList();
      return comments;
    } else {
      throw Exception('Erreur de chargement');
    }
  }

  Future<Comment> createComment(Comment comment) async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(comment.toJson()),
    );

    if (response.statusCode == 201) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur de Création');
    }
  }

  Future<void> updateComment(Comment comment) async {
    final response = await http.put(
      Uri.parse("https://jsonplaceholder.typicode.com/comments/${comment.id}"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(comment.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur de mis à jour');
    }
  }

  Future<void> deleteComment(int id) async {
    final response = await http
        .delete(Uri.parse('https://jsonplaceholder.typicode.com/comments/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erreur de suppression');
    }
  }
}