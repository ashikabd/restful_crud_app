# RESTful CRUD App – Flutter + Firebase + GetX

A cross-platform Flutter application featuring **phone-based OTP authentication**, **full CRUD operations**, **pagination**, and a responsive UI. Built with **GetX** for routing, dependency injection, and state management, and **Firebase** for authentication.

---

## Important Links

**Deployed Web App:**
[https://restful-crud-app.web.app/#/home](https://restful-crud-app.web.app/#/home)

**Android App APK:**
[https://drive.google.com/file/d/1VuL_LqcypgiKzm-pTZsw5G6IB2p6e1sy/view?usp=sharing](https://drive.google.com/file/d/1VuL_LqcypgiKzm-pTZsw5G6IB2p6e1sy/view?usp=sharing)

**Project Walkthrough Video:**
[https://drive.google.com/file/d/13A_YdwnIMjYRYn2qoHQhLGDJ01p8W4IQ/view?usp=sharing](https://drive.google.com/file/d/13A_YdwnIMjYRYn2qoHQhLGDJ01p8W4IQ/view?usp=sharing)


---

## Features

* Firebase Phone Authentication (mobile & web)
* Create / Read / Update / Delete (CRUD) via REST API
* Optimistic UI updates with rollback on API failure
* Pagination (incremental loading of items)
* Form validation with user-friendly error handling
* Responsive design (mobile + web)
* Clean architecture: models → services → controllers → views
* State management, routing, and DI using GetX
* Unit test coverage for key modules

---

## Setup Instructions

### 1. Prerequisites

* Flutter SDK (v3.22+ recommended)
* Firebase Project
* Android Studio or VS Code with Flutter/Dart extensions

Verify installation:

```bash
flutter doctor
```

---

## 2. Firebase Configuration

### Enable Phone Authentication

1. Open Firebase Console
2. Navigate to **Authentication → Sign-in method**
3. Enable **Phone** login
4. (Optional for development) Add test phone numbers in the whitelisted section

---

### Android Setup

1. Register your Android app in Firebase
2. Download and place `google-services.json` in `android/app/`
3. Add to `android/build.gradle`:

```gradle
classpath 'com.google.gms:google-services:4.3.15'
```

4. Add to `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

5. Ensure:

```
minSdkVersion 21
```

---

### Web Setup

1. Register a Web app in Firebase
2. Copy the Firebase config object
3. Add the following to `web/index.html` **before `</body>`**:

```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>

<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

Note: Firebase web config values are public and safe to commit.

---

## 3. Install Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  http: ^1.1.2
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

Install packages:

```bash
flutter pub get
```

---

## 4. Run the App

```bash
flutter run            # Mobile  
flutter run -d chrome  # Web
```

---

## Project Structure

```
lib/
├── main.dart               
├── models/
│   └── api_object.dart     
├── services/
│   └── api_service.dart    
├── controllers/
│   ├── auth_controller.dart
│   └── object_controller.dart
└── views/
    ├── splash_screen.dart
    ├── auth/
    │   └── login_screen.dart
    └── home/
        ├── home_screen.dart
        ├── detail_screen.dart
        └── form_screen.dart
```

### Architectural Decisions

* **Clear separation of concerns** ensures maintainability and testability
* **GetX** simplifies state management, routing, and dependency injection
* **Optimistic updates** enhance UX with instant UI changes
* **REST-first design** demonstrates integration with external APIs beyond Firebase

---

## Limitations

* Only phone-based OTP authentication is included
* Uses a mock REST API—replace with your backend for production
* Limited local persistence (in-memory only)
* No dark mode or extensive UX customization
* Web relies on Firebase reCAPTCHA; mobile requires SIM for OTP

---

## Future Enhancements

* Email/password and Google Sign-In
* Local caching using Hive or SQLite
* Search and filtering functionality
* Dark theme support
* Image uploads via Firebase Storage
* Integration and widget tests
* Deployable backend using Firebase Functions or custom API

---

## Deployment

### Android APK

```bash
flutter build apk --release
```

### Web Build

```bash
flutter build web
```

Deployable to Firebase Hosting, Netlify, Vercel, or GitHub Pages.

---

## Testing

Run unit tests:

```bash
flutter test
```

Tests include:

* `ApiService` (mock HTTP interactions)
* `ObjectController` logic
---
