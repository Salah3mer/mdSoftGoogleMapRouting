# Google Map Routing Flutter 🗺️

A powerful Flutter package for real-time navigation and route tracking using Google Maps API. This package supports background location updates, route calculation, and customizable map styles.

---

## Features ✨

- **Real-time location tracking**: Get live updates of the user's location.
- **Background service**: Continuously track location even when the app is in the background.
- **Route calculation**: Calculate and display the best route between two points.
- **Customizable map styles**: Apply custom map themes (e.g., dark mode, light mode).
- **Destination reached notification**: Notify the user when they reach their destination.
- **Smooth animations**: Animated camera movements and marker transitions.
- **Waypoints support**: Define multiple stop points along the route for more complex navigation flows.
- **Points naming**: Introduced `pointsName` parameter to easily label and identify each location.

---

## Installation 📦

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  # mdsoft_google_map_routing: ^<latest_version>  
  mdsoft_google_map_routing:
   git: 'https://github.com/Salah3mer/mdSoftGoogleMapRouting.git' 
  
```

---

## Required Permissions 🔒

- **Android**: Add the following permissions to your `android/app/src/main/AndroidManifest.xml` file

```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools" package="com.example.example">
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.VIBRATE" /> 
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<application

<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="YOUR_API_KEY"/>
     </activity>
     ....
     </activity>

     <service
            android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="location" />
  ...>
```

- Add the following dependencies to your `android/gradle/wrapper/gradle-wrapper.properties` file

 ```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip
  ```

- Add the following dependencies to your `android/app/build.gradle` file

 ```gradle
android {
    compileSdk = 35
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }
}
  ```

- Add the following dependencies to your `android/settings.gradle` file

 ```gradle
plugins {
    id "com.android.application" version "8.3.2" apply false
}
  ```

- **iOS**: Add the following permissions to your `ios/Runner/Info.plist` file

``` plist
<!-- Info.plist snippet for iOS -->
<dict>
  <!-- Location Permissions -->
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>This app requires access to your location to provide routing features.</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>This app requires always-on location access for background navigation.</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>This app needs access to your location both in the foreground and background for route tracking.</string>

  <!-- Background Modes: Enable location updates in the background -->
  <key>UIBackgroundModes</key>
  <array>
      <string>location</string>
  </array>
  <!-- Internet access is granted by default; no explicit key needed for INTERNET permission. -->

  <!-- For notifications, iOS requires you to request permission at runtime via UNUserNotificationCenter -->
</dict>
```

---

- **Web**: Add the following permissions to your `web/index.html` file in the `head` section

``` <script src="https://maps.googleapis.com/maps/api/js?key=APIKEY"></script> ```

## Usage 🚀

- Before running the app, ensure that you have set up all necessary permissions (Permission.notification ,Permission.location) and API keys (Google Maps API key) in your `AndroidManifest.xml` and `Info.plist.

- Add the following code to your main.dart file to initialize the package:

```dart
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  //Here you can add your ask for permission such as location, notification etc


  // Initialize GoogleMapConfig with your API Key.
  GoogleMapConfig.initialize(
    apiKey: 'Your API Key',
    socketBaseUrl : 'Your Socket Base URL',
  );

  ```

- `tripStatusListener`: A callback function that listens for changes in the trip status. Use this to handle updates such as trip start, progress, completion, or cancellation, allowing your app to respond accordingly.

``` dart
  GoogleMapConfig.tripStatusListener.listen((status) {
    debugPrint("Trip Status: $status");
    switch (status) {
      case TripStatus.driverArrived:
        debugPrint("Driver has arrived to user.");
        break;
      case TripStatus.completed:
        debugPrint("Trip has been completed.");
        break;
      case TripStatus.cancelled:
        debugPrint("Trip has been cancelled.");
        break;
    }
  });
  ```

- To use the Google Map Routing widget in your app, simply include it in your widget tree. For example:

```dart
  MdSoftGoogleMapRouting(
  isViewTrip : false , // its by defalut  false if you wont just to see trip make it true 
  
// 1 - make the car location start location 
// 2 - make the start location end location  
// 3 - make the end  location MdSoftLatLong (0,0) 
//? you can send way points  if it exist it will be shown like view 
   
  tripId: '6849443fc18ee0129c3b7ee8',
  driverId: '68481db7e4d29e0b70233043',
  isUser : false,  // true or false if  it user or admin  make it true  if  it driver make it false the default is false
  mapStyle: 'assets/json/map_style.json', // Path to your custom map style JSON file.
  startLocation: MdSoftLatLng(30.7052, 31.2677), // Define the start location.
  endLocation: MdSoftLatLng(30.706341997359363, 31.26516825147782), // Define the destination.
  carPosstion: MdSoftLatLng(30.706341997359363, 31.26516825147782), // Posstion the Car Location if it not exist   MdSoftLatLng(0,0).
  waypoints : [MdSoftLatLng(30.7052, 31.2677),MdSoftLatLng(30.7052, 31.2677)]  , //Define waypoints as List of MdSoftLatLng objects.
  pontsName:['startPointName', 'endPointName' ...[list of waypoints name]], // you must send  'startPointName', 'endPointName' ,  Define waypoints name as List of String.
),
