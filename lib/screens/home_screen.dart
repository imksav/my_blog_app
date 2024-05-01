import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_blog_app/models/blog.dart';
import 'package:my_blog_app/screens/add_blog_screen.dart';
import 'package:my_blog_app/screens/blog_detail_screen.dart';
import 'package:my_blog_app/utils/db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Blog>> _blogsFuture;
  List<Blog> _blogs = [];
  List<Blog> _selectedBlogs = [];
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      _blogsFuture = DatabaseHelper.instance.getAllBlogs();
      _selectedBlogs.clear();
      _isSelecting = false;
    });
  }

  Future<void> _searchBlogs(String query) async {
    setState(() {
      _blogsFuture = DatabaseHelper.instance.searchBlogs(query);
    });
  }

  void _toggleSelect(Blog blog) {
    setState(() {
      if (_selectedBlogs.contains(blog)) {
        _selectedBlogs.remove(blog);
      } else {
        _selectedBlogs.add(blog);
      }
    });
  }

  void _deleteSelectedBlogs() async {
    for (Blog blog in _selectedBlogs) {
      await DatabaseHelper.instance.deleteBlog(blog.id!);
    }
    _refreshBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelecting
            ? Text('${_selectedBlogs.length} selected')
            : Text('Blog App'),
        actions: _isSelecting
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteSelectedBlogs(),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    final String? query = await showSearch(
                      context: context,
                      delegate: BlogSearchDelegate(),
                    );
                    if (query != null) {
                      _searchBlogs(query);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.select_all),
                  onPressed: () {
                    setState(() {
                      _selectedBlogs.clear();
                      if (_blogs.length == _selectedBlogs.length) {
                        _isSelecting = false;
                      } else {
                        _selectedBlogs.addAll(_blogs);
                        _isSelecting = true;
                      }
                    });
                  },
                ),
              ],
      ),
      body: FutureBuilder<List<Blog>>(
        future: _blogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          _blogs = snapshot.data ?? [];
          return ListView.builder(
            itemCount: _blogs.length,
            itemBuilder: (context, index) {
              Blog blog = _blogs[index];
              return _buildBlogTile(blog);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBlogScreen(),
            ),
          ).then((_) => _refreshBlogs());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBlogTile(Blog blog) {
    return ListTile(
      leading: _isSelecting
          ? Checkbox(
              value: _selectedBlogs.contains(blog),
              onChanged: (value) => _toggleSelect(blog),
            )
          : null,
      title: Text(blog.title),
      subtitle: Text("By: ${blog.author}"),
      trailing: Card(
        child: Image.file(
          File(blog.imagePath!),
          height: 200,
        ),
      ),
      onTap: () {
        if (_isSelecting) {
          _toggleSelect(blog);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(blog: blog),
            ),
          ).then((_) => _refreshBlogs());
        }
      },
    );
  }
}

class BlogSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
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
    return FutureBuilder<List<Blog>>(
      future: DatabaseHelper.instance.searchBlogs(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<Blog> searchResults = snapshot.data ?? [];

        return ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(searchResults[index].title),
              subtitle: Text(searchResults[index].author),
              onTap: () {
                close(context, searchResults[index].title);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
