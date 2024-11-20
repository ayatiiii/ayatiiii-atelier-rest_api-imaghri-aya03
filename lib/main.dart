import 'package:flutter/material.dart';
import 'package:rest_api/models/comment.dart';
import 'package:rest_api/Commentrepository.dart'; // Assurez-vous que le fichier a bien ce nom et cette casse.

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommentScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CommentScreen extends StatefulWidget {
  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final Commentrepository _repository = Commentrepository();
  late Future<List<Comment>> _comments;

  @override
  void initState() {
    super.initState();
    _comments = _repository.fetchComments();
  }

  void _refreshComments() {
    setState(() {
      _comments = _repository.fetchComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaires'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshComments,
          ),
        ],
      ),
      body: FutureBuilder<List<Comment>>(
        future: _comments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun commentaire disponible'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final comment = snapshot.data![index];
                return ListTile(
                  title: Text(comment.name),
                  subtitle: Text(comment.body),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteComment(comment.id),
                  ),
                  onTap: () => _showUpdateCommentDialog(comment),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCommentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteComment(int id) async {
    try {
      await _repository.deleteComment(id);
      _refreshComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  void _showCreateCommentDialog() {
    _showCommentDialog(
      onConfirm: (comment) async {
        try {
          await _repository.createComment(comment);
          _refreshComments();
          Navigator.of(context).pop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      },
    );
  }

  void _showUpdateCommentDialog(Comment comment) {
    _showCommentDialog(
      initialComment: comment,
      onConfirm: (updatedComment) async {
        try {
          await _repository.updateComment(updatedComment);
          _refreshComments();
          Navigator.of(context).pop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e')),
          );
        }
      },
    );
  }

  void _showCommentDialog({
    Comment? initialComment,
    required Function(Comment) onConfirm,
  }) {
    final postIdController =
    TextEditingController(text: initialComment?.postId.toString() ?? '');
    final nameController =
    TextEditingController(text: initialComment?.name ?? '');
    final emailController =
    TextEditingController(text: initialComment?.email ?? '');
    final bodyController =
    TextEditingController(text: initialComment?.body ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialComment == null
            ? 'Créer un commentaire'
            : 'Modifier le commentaire'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: postIdController,
                decoration: const InputDecoration(labelText: 'Post ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Commentaire'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final postId = int.tryParse(postIdController.text) ?? 0;
              final name = nameController.text;
              final email = emailController.text;
              final body = bodyController.text;

              if (postId > 0 &&
                  name.isNotEmpty &&
                  email.isNotEmpty &&
                  body.isNotEmpty) {
                final comment = Comment(
                  postId: postId,
                  id: initialComment?.id ?? 0,
                  name: name,
                  email: email,
                  body: body,
                );
                onConfirm(comment);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Veuillez remplir tous les champs')),
                );
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
