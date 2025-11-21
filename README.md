# 📻 La Nación Radio – Mobile App

A Flutter mobile application for La Nación Radio, the radio and podcast platform of La Nación, Venezuela’s largest news network. The app integrates podcasts, live radio, news articles, company directories, Instagram reels, YouTube videos, and custom advertising spaces.

---

## 🌍 Overview

La Nación Radio was developed to centralize the company’s radio, podcasts, and news content into a single mobile experience.
The app pulls live data from WordPress, Instagram, and YouTube APIs, and provides a seamless experience with a mini player, custom navigation, and integrated advertising banners.

---

## ✨ Features

- 📻 Live radio streaming & podcast player with mini-player
- 📰 News feed with categories, infinite scroll & webview integration
- 🏢 Company directory with filters, search, and contact info (WhatsApp, Instagram, Website)
- 🎥 Instagram reels & YouTube video integration
- 🖼️ Advertising banners intercalated across all views
- ❄️ Frosted glass-style AppBar with blur effect
- ⚡ Error handling with retry dialog (when controllers fail to load)
- 🔄 Modular controllers for ads, audio, navigation, news, reels, and WordPress API

---

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** WordPress (REST API)
- **Media APIs:** YouTube API, Instagram Graph API
- **State Management:** Custom controllers with `app_state.dart`
- **UI:** Flutter Widgets + Custom Components
- **Ads:** Custom ad manager + API integration

---

## 📂 Project Structure

```text
assets/
 ├── audio/
 ├── fonts/
 ├── icons/
 ├── images/
 └── .env
lib/
 ├── main.dart
 ├── app/
 ├── config/
 ├── utils/
 ├── widgets/
 └── dashboard/
```

---

## ⚙️ Installation & Setup

### Requirements

- Flutter SDK (v3.x or higher)
- Dart (>=2.17)
- Android Studio / VS Code with Flutter plugin
- Git

### Clone Repository

```bash
git clone https://github.com/Fockus26/La-Nacion-Radio-Mobile-App.git
cd la-nacion-radio-mobile-app
```

### Install Dependencies

```bash
flutter pub get
```

### Environment Variables

Create a `.env` file at the root with the following:

```env
# Instagram
INSTAGRAM_ACCESS_TOKEN=
INSTAGRAM_USER_ID=

# RapidAPI
RAPID_KEY=

# YouTube
YOUTUBE_API_KEY=
YOUTUBE_CHANNEL_ID=
YOUTUBE_UPLOAD_PLAYLIST_ID=
```

### Run Locally

```bash
flutter run
```

By default, the app runs in debug mode on the connected device/emulator.

### Build APK

```bash
flutter build apk --release
```

The APK will be located at:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📖 Case Study

La Nación Radio was requested by the company to modernize its digital presence and unify content in a mobile-first solution.
While website adjustments were handled directly via WordPress, the app development required integrating multiple content sources (WordPress, Instagram, YouTube) with a clean UI and custom ads.

---

## 📈 Future Improvements

- 📲 Push notifications for new podcasts & news
- 🔗 Deep links for direct access to specific news or radio shows
- 🌐 Offline mode for cached news and podcasts
- 🧪 Unit tests for controllers and API integrations

---

## 📜 License

This project is private and proprietary. Distribution or reuse without explicit authorization from La Nación Radio is not allowed.
