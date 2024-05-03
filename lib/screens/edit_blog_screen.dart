import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_blog_app/models/blog.dart';
import 'package:my_blog_app/utils/db_helper.dart';

class EditBlogScreen extends StatefulWidget {
  final Blog blog;

  EditBlogScreen({required this.blog});

  @override
  _EditBlogScreenState createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  late File? _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // all previously added data will be assigned initally
    _titleController.text = widget.blog.title;
    _descriptionController.text = widget.blog.description;
    _authorController.text = widget.blog.author;
    _dateController.text = widget.blog.date;
    _tagsController.text = widget.blog.tags.join(', ');
    _imageFile =
        widget.blog.imagePath != null ? File(widget.blog.imagePath!) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Blog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null,
                textInputAction: TextInputAction.none,
              ),
              SizedBox(height: 12.0),
              _imageFile != null
                  ? Center(
                      child: Image.file(
                        _imageFile!,
                        height: 200,
                      ),
                    )
                  : Placeholder(
                      fallbackHeight: 200,
                    ),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      getImage(ImageSource.camera);
                    },
                    child: Text('Upload By Camera'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    },
                    child: Text('Upload By Gallery'),
                  ),
                ],
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Author'),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2015, 8),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final DateTime selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _dateController.text = selectedDateTime.toString();
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 12.0),
              TextField(
                controller: _tagsController,
                decoration:
                    InputDecoration(labelText: 'Tags (comma-separated)'),
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  _saveBlog();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

// saves the changes in the field and assign them to the variable
  void _saveBlog() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final String author = _authorController.text;
    final String date = _dateController.text;
    final String tags = _tagsController.text;

// check validation
    if (title.isEmpty ||
        description.isEmpty ||
        author.isEmpty ||
        date.isEmpty ||
        tags.isEmpty) {
      return;
    }

    final String? imagePath = _imageFile?.path;

    final Blog updatedBlog = widget.blog.copyWith(
      title: title,
      description: description,
      author: author,
      date: date,
      tags: tags.split(','),
      imagePath: imagePath,
    );

    await DatabaseHelper.instance.updateBlog(updatedBlog);

    Navigator.pop(context);
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
}
