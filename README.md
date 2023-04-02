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
Users signing in with a Google account (via Google authorisation) are automatically assigned a profile picture from their user account. Users are also able to click on their profile feature in the nav drawer and change their profile picture.

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

- ![](https://i.ibb.co/HrW0kRm/project-filtering.png)

### 2.9	Project Favourites
Client users can click the favourite button on any Project, which will add to a personalised list of favourites. Favourite projects can also be viewed on a map.

![](https://i.ibb.co/PCBGcJ7/favourite-projects.png)

### 2.10 Vendor Favourites and Associated Details/Projects
Client users can also click the favourite button for a Vendor when viewing a Project, allowing them to create a list of favourite Vendors. They can also view details of each Vendor, or view the Projects associated with a particular Vendor (including on a map view).

![](https://i.ibb.co/7gMXDGp/vendor-favourites-details.png)

### 2.11 Client Requests 
Similar to the ability for Vendor users to create Projects, Client users can create Requests, essentially advertising for a future Project they wish to have completed. Clients are able to create, update, and delete Requests, while Vendors are able to see a list or map of Requests, and use a search function to filter Requests. 

![](https://i.ibb.co/Rbw0c3x/client-requests.png)

### 2.12 Vendor Responses to Requests
Upon viewing a Request that a Vendor user would like to take on, the Vendor can then create a Response. There can be multiple Responses per Request (only one per Vendor), which the Client can see listed. A Vendor user can also see a list of all Responses they've provided to different Requests.  

![](https://i.ibb.co/P5rwPhS/vendor-responses.png)

### 2.13 Vendor/Client Messaging
Within any Response screen, there is the ability for both Clients and Vendors to add Messages. This allows for in-built dialogue between users, where any questions of clarifications can be addressed.

![](https://i.ibb.co/ZM4n0zc/client-vendor-messages.png)

### 2.14 State Management
State management in the Spruuk app has been supported by the Riverpod library, which Remi Rousselet created in 2020 as a follow up to the popular Provider state management framework. See [here](https://riverpod.dev/) for a comprehensive set of documentation and explanation for Riverpod's usage and capabilities. 

## 3   Firestore Collections
### 3.1 vendor_users
The naming of this collection is a little misleading, as it actually includes all users, including Clients and Vendors. As per the User model, fields include: 
- email - the user's email address.
- firstName - the user's first name.
- lastName - the user's surname.
- password - this includes the setup password that the user takes. If they choose to sign in through Google Authorisation then it is set to "Google User" as default. If they reset their password using the password reset function there is no change to the password in collections. This field could be removed.
- uid - the unique identification code assigned to a user as part of Firebase Authentication.
- userImage - the Firebase or Google Accounts address for the user's profile image.
- userProjectFavourites - a list of project identification numbers that a Client user has favourited.
- userType - a selection of Client or Vendor
- userVendorFavourites - a list of Vendor identification numbers that a Client user has favourited.

### 3.2 projects
This is a collection of all the Projects uploaded by Vendor users. As per the Project model, fields include: 
- projectArea - the square meter area of a Project.
- projectBriefDescription - a shortened description of the Project.
- projectCompletionDay - the day of the month a Project was completed (numerical).
- projectCompletionMonth - the month of the year a Project was completed (numerical).
- projectCompletionYear - the year a Project was completed. 
- projectConsented - this is a boolean field for future functionality where only Projects that have received owner's consent will be uploaded to the Spruuk app. 
- projectFavouriteUserIds - this is a list of all the user's that have favourited a project, allowing for future functionality of the app to assess performance metrics of posts. 
- projectId - the unique identification code of the Project. 
- projectImages - a list of Firebase cloud storage addresses for images related to a particular Project. 
- projectLat - the latitude of a Project. 
- projectLng - the longitude of a Project. 
- projectLongDescription - a longer description of the Project. 
- projectMaxCost - the maximum price range for a Project. 
- projectMinCost - the minimum price range for a Project. 
- projectStyle - a selection of Traditional, Contemporary, Modern, Retro, Minimalist, or None to describe the style of a Project. 
- projectTitle - the main title of a Project. 
- projectType - a selection of New Build, Renovation, Landscaping, Interiors, or Commercial to describe the general Project type. 
- projectUserEmail - the email address of the Vendor who created the Project. 
- projectUserId - the unique identification code of the Vendor who created the Project. 
- projectUserImage - the Firebase storage or Google Account address of the image relating to the Vendor who set up the Project. 
- projectZoom - the zoom setting for viewing a particular Project on Google Maps. 

### 3.3 requests
This is a collection of all the Requests uploaded by Client users. As per the Request model, fields include:
- requestArea - the square meter area of a Request.
- requestBriefDescription - a shortened description of the Request.
- requestCompletionDay - the day of the month a Request was completed (numerical).
- requestCompletionMonth - the month of the year a Request was completed (numerical).
- requestCompletionYear - the year a Request was completed.
- requestId - the unique identification code of the Request.
- requestImages - a list of Firebase cloud storage addresses for images related to a particular Request.
- requestLat - the latitude of a Request.
- requestLng - the longitude of a Request.
- requestLongDescription - a longer description of the Request.
- requestMaxCost - the maximum price range for a Request.
- requestMinCost - the minimum price range for a Request.
- requestStyle - a selection of Traditional, Contemporary, Modern, Retro, Minimalist, or None to describe the style of a Request.
- requestTitle - the main title of a Request.
- requestType - a selection of New Build, Renovation, Landscaping, Interiors, or Commercial to describe the general Request type.
- requestUserEmail - the email address of the Vendor who created the Request.
- requestUserId - the unique identification code of the Vendor who created the Request.
- requestUserImage - the Firebase storage or Google Account address of the image relating to the Vendor who set up the Request.
- requestZoom - the zoom setting for viewing a particular Request on Google Maps. 

### 3.4 responses
This is a collection of all the Responses created by Vendor users in response to Client user requests. As per the Response model, fields include: 
- responseCompletionDay - the day of the month a Response was completed (numerical).
- responseCompletionMonth - the month of the year a Response was completed (numerical).
- responseCompletionYear - the year a Response was completed.
- responseDescription - the general description of a Response provided by a Vendor user. 
- responseId - the unique identification code of the Response. 
- responseMessageIds - the unique identification codes of the Messages related to a particular response (i.e. those provided by Client and Vendor users).
- responseRequestId - the unique identification code of the particular Request the Response is related to.
- responseTitle - the general title of a Response. 
- responseUserEmail - the email address of the Vendor user that created the Response. 
- responseUserFirstName - the first name of the Vendor user that created the Response. 
- responseUserId - the unique identification code of the Vendor user that created the Response. 
- responseUserImage - the the Firebase storage or Google Account address of the Vendor user that created the Response. 
- responseUserLastName - the last name of the Vendor user that created the Response. 

### 3.5 messages
This is a collection of all the Messages between Vendor and Client users, associated with specific Vendor-related Responses to Client-related Requests. As per the Message model, fields include: 
- messageContent - the general body of the Message.
- messageCreatedDay - the day of the month a Message was created (numerical).
- messageCreatedMonth - the month of the year a Message was created (numerical).
- messageCreatedYear - the year a Message was created.
- messageId - the unique identification code of the Message. 
- messageRequestId - the unique identification code of the Request the Message is associated with (via a Response).
- messageResponseId - the unique identification code of the Response the Message is associated with. 
- messageTimeCreated - the timestamp for when the message was created. 
- messageUserFirstName - the first name of the user that created the Message.
- messageUserId - the unique identification code of the user that created the Message.
- messageUserImage - the the Firebase storage or Google Account address of the user that created the Message.
- messageUserLastName - the last name of the user that created the Message. 
- messageUserType - a selection of either Client of Vendor depending on the type of user who created the message. 

##   4 Dependencies
The following dependencies were used in the Spruuk app to achieve various functionalities.
[cupertino_icons: ^1.0.2](https://pub.dev/packages/cupertino_icons/versions/1.0.2) - access to icons.

[firebase_core: ^2.4.1](https://pub.dev/packages/firebase_core/versions/2.4.1) - access to Firebase Core API for multiple apps.

[firebase_analytics: ^10.1.0](https://pub.dev/packages/firebase_analytics/versions/10.1.0) - access to Firebase Analytics API.

[firebase_auth: ^4.2.5](https://pub.dev/packages/firebase_auth) - access to Firebase Authentication API.

[cloud_firestore: ^4.3.1](https://pub.dev/packages/cloud_firestore/versions/4.3.1) - access to Cloud Firestore API.

[cloud_functions: ^4.0.7](https://pub.dev/packages/cloud_functions/versions/4.0.7) - access to Cloud Functions Firebase API.

[firebase_storage: ^11.0.10](https://pub.dev/packages/firebase_storage) - access to Firebase Cloud Storage API.

[firebase_database: ^10.0.9](https://pub.dev/packages/firebase_database/versions/10.0.9) - access to Firebase Database API.

[flutter_riverpod: ^2.1.3](https://pub.dev/packages/flutter_riverpod) - state-management library.

[google_sign_in: ^5.4.3](https://pub.dev/packages/google_sign_in) - access to Google sign-in.

[envied: ^0.3.0](https://pub.dev/packages/envied/versions/0.3.0) - used to securely handle secret keys.

[font_awesome_flutter: ^10.3.0](https://pub.dev/packages/font_awesome_flutter) - used to provide certain icons.

[dropdown_button2: ^1.9.2](https://pub.dev/packages/dropdown_button2) - used for dropdown menu button.

[image_picker: ^0.8.6+1](https://pub.dev/packages/image_picker) - used for selecting images from different sources.

[image_cropper: ^3.0.1](https://pub.dev/packages/image_cropper) - used for cropping selected images from different sources.

[fluttertoast: ^8.1.2](https://pub.dev/packages/fluttertoast/versions/8.1.2) - used for providing on screen notifications (e.g. errors).

[path_provider: ^2.0.12](https://pub.dev/packages/path_provider) - used for storing temporary files.

[google_maps_flutter: ^2.2.3](https://pub.dev/packages/google_maps_flutter) - used for accessing Google maps.

[location: ^4.4.0](https://pub.dev/packages/location) - used for accessing user's current location.

[flutter_config: ^2.0.0](https://pub.dev/packages/flutter_config) - used for accessing Flutter environmental variables.

[calendar_date_picker2: ^0.3.7](https://pub.dev/packages/calendar_date_picker2/versions/0.3.7) - used for inputting dates.

[date_format: ^2.0.7](https://pub.dev/packages/date_format) - used for formatting dates.

[geolocator: ^9.0.2](https://pub.dev/packages/geolocator) - intended to be used for determining distance between two locations. Couldn't get plugin to work consistently without causing a loss of connection with the device. Perhaps some compatibility issues with other dependencies. 