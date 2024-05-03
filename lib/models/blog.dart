// this is the class model for the database of the application
class Blog {
  final int? id;
  final String title;
  final String description;
  final String author;
  final String date;
  final List<String> tags;
  final String? imagePath;

  Blog({
    this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.date,
    required this.tags,
    this.imagePath,
  });
  Blog copyWith({
    int? id,
    String? title,
    String? description,
    String? author,
    String? date,
    List<String>? tags,
    String? imagePath,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
    );
  }

// it is used to map the data along with the model attributes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'date': date,
      'tags': tags.join(','),
      'imagePath': imagePath ?? '',
    };
  }

// it is used to assign the value to the model attributes from mapping
  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      author: map['author'],
      date: map['date'],
      tags: (map['tags'] as String).split(','),
      imagePath: map['imagePath'],
    );
  }
}
