# MindFlow - AI-Powered Mental Wellness Companion

![MindFlow App Icon](C:/Users/hp/.gemini/antigravity/brain/031545c7-f1b0-4316-8896-82fa2766842a/mindflow_app_icon_1769043803309.png)

## Overview

MindFlow is a cross-platform mental wellness application built with Flutter, designed to help users track their emotional well-being, practice meditation, and connect with a supportive community. The app features AI-powered insights, beautiful animations, and a calming user experience.

## Features

### ✨ Core Features

- **🎭 Interactive Mood Tracking** - Express your feelings with emoji-based mood selection
- **📝 AI Mood Journal** - Voice and text entries analyzed for sentiment patterns
- **🧘 Meditation Library** - Curated sessions (5-20 minutes) with guided breathing exercises
- **📊 Mood Analytics** - Weekly/monthly visualizations with AI-generated insights
- **👥 Anonymous Community** - Share experiences and find peer support
- **🆘 Crisis Resources** - Instant access to hotlines and therapist directories

### 🎨 Design Highlights

- **Glassmorphism 2.0** - Frosted glass effects with layered transparency
- **Calming Gradients** - Purple to teal color spectrum for relaxation
- **Dark Mode First** - Optimized for reduced eye strain
- **Smooth Animations** - 60 FPS spring physics and micro-interactions
- **Haptic Feedback** - Tactile responses for all interactions
- **Accessibility First** - WCAG 2.1 AA compliant, screen reader support

## Screenshots

### Splash Screen
![Splash Screen](C:/Users/hp/.gemini/antigravity/brain/031545c7-f1b0-4316-8896-82fa2766842a/mindflow_splash_screen_1769043834584.png)

### Onboarding
![Onboarding](C:/Users/hp/.gemini/antigravity/brain/031545c7-f1b0-4316-8896-82fa2766842a/mindflow_onboarding_illustration_1769043859734.png)

## Tech Stack

- **Framework**: Flutter 3.x (Dart)
- **State Management**: Riverpod 2.x
- **Backend**: Firebase Suite (Auth, Firestore, Storage, Analytics, FCM)
- **Local Storage**: Hive + flutter_secure_storage
- **Animations**: Lottie, flutter_staggered_animations
- **UI Components**: GetWidget, custom Material Design 3 widgets
- **Voice**: speech_to_text, flutter_tts
- **Typography**: Google Fonts (Inter, Outfit)

## Project Structure

```
mindflow/
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart       # Color palette & gradients
│   │   │   ├── app_text_styles.dart  # Typography system
│   │   │   └── app_theme.dart        # Material Design 3 themes
│   │   ├── constants/
│   │   ├── utils/
│   │   └── services/
│   ├── features/
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       └── widgets/
│   │   │           ├── mood_selector.dart
│   │   │           ├── quick_action_card.dart
│   │   │           └── mood_chart.dart
│   │   ├── journal/
│   │   ├── meditation/
│   │   ├── community/
│   │   └── profile/
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── glassmorphic_container.dart
│   │   │   └── gradient_button.dart
│   │   └── animations/
│   └── main.dart
├── assets/
│   ├── images/
│   ├── fonts/
│   └── animations/
└── pubspec.yaml
```

## Installation & Setup

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- Firebase project (for backend services)

### Steps

1. **Clone the repository**
   ```bash
   cd All_Apps/mindflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome
   ```

## Development Guidelines

### Code Style
- Follow Dart official style guide
- Use meaningful variable names
- Comment complex logic
- Extract reusable widgets

### State Management
- Use Riverpod providers for state
- Keep business logic separate from UI
- Implement proper error handling

### UI/UX Principles
- Maintain 60 FPS animations
- Test on multiple screen sizes
- Ensure proper contrast ratios
- Implement loading states

## Monetization Strategy

### Freemium Model
**Free Tier:**
- Basic mood tracking
- Limited meditation sessions
- Community access
- Basic analytics

**Premium Tier** ($9.99/month or $79.99/year):
- Unlimited AI insights
- Advanced analytics
- Full meditation library
- Therapist directory
- Ad-free experience

**Rewarded Ads:**
- Free users watch ads for 1-day premium feature access

## Roadmap

### Version 1.0 (MVP) ✅
- [x] Core UI/UX design system
- [x] Home screen with mood tracking
- [x] Mood analytics chart
- [x] Glassmorphic components
- [ ] Journal feature
- [ ] Meditation library
- [ ] Community forums
- [ ] User profile

### Version 2.0
- [ ] AI Chat Companion (GPT-4 integration)
- [ ] Sleep sound generator
- [ ] Wearable integration (Apple Watch, Fitbit)
- [ ] Therapist matching service
- [ ] Offline mode
- [ ] Multi-language support

## Performance Targets

- **App Size**: < 50MB (uncompressed)
- **Launch Time**: < 2 seconds
- **Frame Rate**: 60 FPS minimum
- **Memory**: < 200MB average usage
- **Crash Rate**: < 0.1%

## Testing

```bash
# Run unit tests
flutter test test/unit/

# Run widget tests
flutter test test/widgets/

# Run integration tests
flutter test integration_test/
```

## Contributing

This is a commercial project. For contributions or suggestions, please contact the development team.

## License

Proprietary - All rights reserved

## Contact & Support

- **App Website**: [Coming Soon]
- **Support Email**: support@mindflowapp.com
- **Social Media**: @mindflowapp

---

**Built with ❤️ using Flutter**

*MindFlow - Your journey to mental wellness starts here.*
