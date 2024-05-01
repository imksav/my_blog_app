# my_blog_app

## Table of Contents
- [my\_blog\_app](#my_blog_app)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Assessment's Requirement](#assessments-requirement)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Packages and their version](#packages-and-their-version)
  - [Contributing](#contributing)
  - [License](#license)
  - [Version: v1.0](#version-v10)

## Introduction
This application is developed during the assessment of 7CC012 - Mobile Application Development in MSc Computer Science. It is a simple offline blog app which have the features like CRUD operation along with search and multiple deletion of the blog items. It can be shared to other platform in which Internet is required. 

## Assessment's Requirement
To design and develop a mobile which functions as an offline blogging client. The application must meet the following requirements:
1. Accept text input for a blog item.
2. Managing blog items on the device.
a. Create, edit, view and delete blog items.
b. View individual blog items.
c. View the current list of blog items. 
d. Search for text within the blog items and display either the first matching item, or a list of matching blog items.
e. Delete a single blog item.
f. Select and delete a group of chosen blog items.
3. The individual blog item must have the following fields:
a. Title
b. Date of blog item entry
c. Main blog item body text
d. Image
4. Must store the blog items in a database on the device.
5. Attach a photo or an image to a blog item, from the photo gallery and camera.
6. "Share" individual blog item (title, text and image) by email via the standard platform "Share" mechanism.
7. All of the mobile app's functionality must be functional offline, i.e. when the mobile device is not connected to any network, except for the sharing via email part.
8. You must implement the mobile app using Google Flutter.
9. The mobile app code must be portable between Android and iOS.
**All the above requirements are fulfilled.**

## Installation
1. Clone the repository:
   ```
   git clone https://github.com/imksav/my_blog_app.git
   ```
   
## Usage
To run the project, use the following command:
open the folder cloned in command prompt
```
cd my_blog_app
flutter pub get
flutter run
```

## Packages and their version
sqflite: ^2.0.0
path_provider: ^2.0.2
image_picker: ^0.8.0
datetime_picker_formfield_new: ^2.1.0
intl: ^0.19.0
share: ^2.0.4

## Contributing
1. Fork the repository.
2. Create a new branch: `git checkout -b feature-name`.
3. Make your changes.
4. Push your branch: `git push origin feature-name`.
5. Create a pull request.

## License
This project is licensed under the [MIT License](LICENSE).

## Version: v1.0