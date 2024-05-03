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

// this function  will refresh the list of blogs and update to the screen
  Future<void> _refreshBlogs() async {
    setState(() {
      _blogsFuture = DatabaseHelper.instance.getAllBlogs();
      _selectedBlogs.clear();
      _isSelecting = false;
    });
  }

// this function is used to search the blog details in an app
  Future<void> _searchBlogs(String query) async {
    setState(() {
      _blogsFuture = DatabaseHelper.instance.searchBlogs(query);
    });
  }

// this is to make a group of selection for group delete
  void _toggleSelect(Blog blog) {
    setState(() {
      if (_selectedBlogs.contains(blog)) {
        _selectedBlogs.remove(blog);
      } else {
        _selectedBlogs.add(blog);
      }
    });
  }

// thi function will delete the selected blogs using the toogle select function
  void _deleteSelectedBlogs() async {
    for (Blog blog in _selectedBlogs) {
      await DatabaseHelper.instance.deleteBlog(blog.id!);
    }
    // after deletion of the application, it will refresh the list of blogs and update to the screen
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
            return Center(
              // it will show the circular progress gif in home screen when data being fetched from the database
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          _blogs = snapshot.data ?? [];
          return ListView.builder(
            itemCount: _blogs.length,
            itemBuilder: (context, index) {
              Blog blog = _blogs[index];
              // after getting the data from the database it will be passed to the create an widget to display
              return _buildBlogTile(blog);
            },
          );
        },
      ),
      // this button is used to add post
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // navigation to the blog adding screen
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
              // once we click on any blog item, it will navigate to the detail screen of that blog item
              builder: (context) => BlogDetailScreen(blog: blog),
            ),
          ).then((_) => _refreshBlogs());
        }
      },
    );
  }
}

// this is the class for the search function
class BlogSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // at the beginning it will be blank as we don't apply any sql
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
// list of data search will be displayed after clicking on search button
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
