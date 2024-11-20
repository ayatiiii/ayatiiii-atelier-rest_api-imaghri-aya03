import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/comment.dart'; // Assurez-vous que ce chemin pointe vers votre modèle `Comment`

Future<List<Comment>> fetchComments() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Comment.fromJson(json)).toList();
  } else {
    throw Exception('Erreur lors de la récupération des commentaires');
  }
}
