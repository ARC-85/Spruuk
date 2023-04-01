# Spruuk : An app to showcase local construction and landscaping projects
## A final year project for the SETU HDip Computer Sciences course.
![](https://res.cloudinary.com/whodunya/image/upload/v1646082553/showcase/310-1-3D_View_1_ersrii.jpg)

## 1   Overview
Spruuk is a hybrid mobile and web application platform built using the Flutter SDK and Dart language, primarily designed to run on Android devices (not fully adjusted for web or iOS). The intended purpose of Spruuk is for companies in the construction and landscaping industries to showcase their portfolios of work to the general public as a form of marketing.

Each “vendor” (i.e. construction or landscaping company) has a profile where they can upload details of individual “projects” (e.g. pictures and details of a new home build), which are grouped under defined categories (e.g. new home builds, extensions, renovations, landscaping, commercial).

Spruuk also allows “clients” (i.e. members of the general public) to browse the projects and apply filters for searching, based on the details provided by vendors. To make searching more interactive for clients, vendors are requested to enter the location of each project, which is then displayed on a map view within the Spruuk app. Using a map view not only allows clients to browse projects in their general area, which provides more relevance to highlighting potential vendors available to them, but also allows them to check the Spruuk app if they see a project in real-life and they would like to know more details on the vendors responsible (e.g. the client drives past a new build home they like and wants to know which architect/builder/etc was responsible).

Both clients and vendors have profiles, which allow for different information to be collected, saved, and displayed. For example, clients are able to save their favourite projects or favourite vendors, which they can view in lists. Vendors are able to see a list of their own projects, which they can update and delete, as well as being able to edit their profiles. There is also a function for clients to post requests for work, which allows responses from multiple vendors. Similar to the ability for clients to search projects posted by vendors, vendors are able to search and view lists of requests posted by clients. Within each vendor response for a particular client request, both clients and vendors can post messages, allowing for inbuilt Q&A within the app.

## 2   Getting Started
**Step 1:**
Set up and install Flutter on your local machine, including setup of Android Studio as an IDE. For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.

**Step 2:**
Download/clone this repo onto your local machine using the following link:
```
https://github.com/ARC-85/Spruuk.git
```
**Step 3:**
Configure the necessary plugins by using Android Studio to navigate to the pubspec.yaml file. Click "Pub get" to get the relevant dependencies, or possibly "Pub upgrade" to update any outdated dependencies. 

**Step 4**
Create a Firebase project including Firestore database, storage, and authentication (see instructions [here](https://docs.flutter.dev/development/data-and-backend/firebase)) and download google-services.json to the appropriate folder (android>app>src).

**Step 5**
It will also be necessary to set up Google maps (see [here](https://developer.android.com/training/maps/index.html)), including establishing a Google maps API key (see [here](https://developers.google.com/maps/documentation/android-api/start#get-key)).
Be sure to insert the API key (e.g. AIzaSXXXXXXXXXXXXXXXXXXXXXXX) in the appropriate location in the AndroidManifest.xml file (android>app>src>main).

**Step 6**
Choose an appropriate emulator device (e.g. Pixel 4 API 31) and run the app via main.dart.

## 2   Spruuk Functionalities
### 2.1	Backend Storage
Firebase is used to manage the backend requirements of the Spruuk app, including Firestore database data storage for text data and Google cloud storage for images. Rules have been set for creating, reviewing, updating, and deleting different collections within the Firestore database, as well as image folders within the cloud storage.

### 2.2	Splash Page
A splash page has been created to great users when first opening the app.
![](https://i.ibb.co/Yf0v8qy/splash-page.png)

### 2.3	Create Account/Sign-in
In addition to the real-time database and cloud storage, Firebase has also been used to handle authentication of users. Users are able to initially create an account using Google authentication within Firebase, or alternatively, they can also use any email/password combination.
![](https://i.ibb.co/T0MRCM4/sign-up.png) ![](https://i.ibb.co/6rztt1Q/login.png)

### 2.4	Nav Drawer
Nav drawer menu functionality allows navigating to different pages depending on user type (Client or Vendor), changing profile details (by clicking profile image), or signing out.
![](https://i.ibb.co/Jk7v6CF/nav-drawer.png)

### 2.5	Profile Updates
Users signing in with a Google account (via Google authorisation) are automatically assigned a profile picture from their user account. Users are also able to click on their profile feature in the nav drawer and change their profile picture
![](https://i.ibb.co/kD9Fcky/update-profile.png)

### 2.6	Creating a New Project
Vendors can create a new Project, including details on features such as:
- Title
- Brief/Long Description
- Type (New Builds, Renovations, Interiors, Landscaping, Commercial)
- Project images (either from the camera or existing gallery images)
- Project location (via Google maps)
- Completion date
- Project style
- Cost/budget range
- Project area
![](https://i.ibb.co/3hkDx96/project-add.png)

### 2.7	Updating or Deleting a Project
To update a Project, the Vendor user clicks on the specific Project in the Project List, which takes them to the Project Detail page. Here, the user can update and save any details. Projects can be deleted by swiping the Project from the Project list.
![](https://i.ibb.co/xJjqYMy/update-delete-project.png)

### 2.8	Project Filtering/Searching
Client users can filter/search for projects by clicking the search button (bottom left corner on Project list), based on criteria related to: 
- Project types
- Search terms
- Distance from user
- Cost range
- Project style
- Completion dates
- Project area
![](https://i.ibb.co/HrW0kRm/project-filtering.png)

### 2.9	Project Favourites
Client users can click the favourite button on any Project, which will add to a personalised list of favourites. Favourite projects can also be viewed on a map.
![](https://i.ibb.co/PCBGcJ7/favourite-projects.png)

### 2.10 Vendor Favourites and Associated Details/Projects
Client users can also click the favourite button for a Vendor when viewing a Project, allowing them to create a list of favourite Vendors. They can also view details of each Vendor, or view the Projects associated with a particular Vendor.
![](https://i.ibb.co/7gMXDGp/vendor-favourites-details.png)

