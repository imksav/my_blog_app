import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_blog_app/models/blog.dart';
import 'package:my_blog_app/screens/edit_blog_screen.dart';
import 'package:share/share.dart';

class BlogDetailScreen extends StatelessWidget {
  final Blog blog;

  BlogDetailScreen({required this.blog});
  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBlogScreen(blog: blog),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _navigateToEditScreen(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              blog.description,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text('Author: ${blog.author}'),
            SizedBox(height: 8.0),
            Text('Posted On: ${blog.date}'),
            SizedBox(height: 8.0),
            Text('Tags: ${blog.tags}'),
            SizedBox(height: 8.0),
            if (blog.imagePath != null && blog.imagePath!.isNotEmpty)
              Image.file(
                File(blog.imagePath!),
                height: 200,
              ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                _shareBlog(context, blog);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareBlog(BuildContext context, Blog blog) {
    final String text =
        'Check out this blog: \n\nTitle: ${blog.title}\n\nDescription: ${blog.description}\n\nPosted on: ${blog.date}\n\nAuthor: ${blog.author}\n\nTags: ${blog.description}';
    Share.share(text, subject: blog.title);
  }
}
