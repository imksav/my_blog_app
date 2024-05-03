import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_blog_app/models/blog.dart';
import 'package:my_blog_app/utils/db_helper.dart';

class AddBlogScreen extends StatefulWidget {
  @override
  _AddBlogScreenState createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  // DateTime? _selectedDate;

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2021),
  //     lastDate: DateTime(2100),
  //   );

  //   if (pickedDate != null) {
  //     setState(() {
  //       _selectedDate = pickedDate;
  //       _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
  //     });
  //   }
  // }

// this function is used to select the image from the different source
// if we select as given option that will be the source value in this function
  Future getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

// this function is called after completing all the field filled to save the blog into database
  Future<void> _saveBlog() async {
    final String title = _titleController.text;
    final String description = _descriptionController.text;
    final String author = _authorController.text;
    final String date = _dateController.text;
    final String tags = _tagsController.text;

// to check validation
    if (title.isEmpty ||
        description.isEmpty ||
        author.isEmpty ||
        date.isEmpty ||
        tags.isEmpty) {
      return;
    }

    final String imagePath = _imageFile?.path ?? '';
    final Blog newBlog = Blog(
      title: title,
      description: description,
      author: author,
      date: date,
      // split function will separte the entry if comma is in between
      // tags field store the list of data
      tags: tags.split(','),
      imagePath: imagePath,
    );

    await DatabaseHelper.instance.insertBlog(newBlog);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Blog'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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

// this is used to select the date and time in which we can select the date range from 2015 to 2101
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
                onPressed: _saveBlog,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
