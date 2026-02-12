# Simon — AI Wellness Coach 🧘‍♀️✨

> Your personal AI-powered mental wellness companion. Personalized meditation, mindfulness coaching, breathing exercises, and more — powered by RevenueCat subscriptions.

**Built for the RevenueCat Hackathon — "Simon" Brief (AI Coaching)**

<p align="center">
  <img src="assets/icon/app_icon.png" width="120" alt="Simon App Icon"/>
</p>

---

## 🌟 What is Simon?

Simon is a comprehensive mental wellness app that combines **AI coaching**, **guided meditation**, **breathing exercises**, **sleep stories**, **journaling**, and **CBT techniques** into one beautiful, dark-mode-first Flutter experience.

The AI coach ("Simon") runs **entirely on-device** using a rule-based therapeutic framework — no external API keys needed. It provides evidence-based guidance using CBT (Cognitive Behavioral Therapy) and mindfulness techniques.

## ✨ Features

### Free Tier
- 🎯 **Mood Tracking** — Daily check-ins with weekly mood charts
- ✍️ **Journaling** — Express thoughts and feelings
- 🌬️ **Breathing Exercises** — Box breathing, 4-7-8, and more
- 📊 **Wellness Score** — Track your overall wellness
- 🙏 **Gratitude Practice** — Daily gratitude entries
- 🧠 **CBT Tools** — Cognitive reframing exercises
- 🆘 **Crisis Resources** — Immediate support when needed
- 👤 **Profile & Streaks** — Track your consistency

### Premium (via RevenueCat) 💎
- 🤖 **AI Wellness Coach** — Chat with Simon for personalized CBT-based guidance
- 😴 **Sleep Stories** — Calming narrated stories for peaceful sleep
- 🧘 **Body Scan** — 15-region progressive relaxation (4 min guided)
- ✨ **Daily Affirmations** — Swipeable positive affirmations
- 🔓 **Unlimited Meditations** — Full library access
- 📈 **Advanced Analytics** — Deep wellness insights

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/         # App constants
│   ├── models/            # Data models (mood, journal, etc.)
│   ├── providers/         # Riverpod state providers
│   ├── services/          # Storage, RevenueCat service
│   ├── theme/             # Colors, typography, themes
│   └── utils/             # Helpers
├── features/
│   ├── affirmations/      # 🆕 Daily affirmations (Premium)
│   ├── bodyscan/          # 🆕 Guided body scan (Premium)
│   ├── breathing/         # Breathing exercises
│   ├── cbt/               # CBT cognitive reframing
│   ├── coach/             # 🆕 AI wellness coach (Premium)
│   ├── community/         # Community features
│   ├── crisis/            # Crisis resources
│   ├── discover/          # 🆕 Feature discovery & paywall
│   ├── gratitude/         # Gratitude journal
│   ├── home/              # Home screen & navigation
│   ├── journal/           # Journaling
│   ├── meditation/        # Guided meditations
│   ├── paywall/           # 🆕 RevenueCat paywall
│   ├── profile/           # User profile
│   └── sleep/             # 🆕 Sleep stories (Premium)
└── shared/
    └── widgets/           # Reusable widgets (glass cards, buttons)
```

## 💰 RevenueCat Integration

Simon uses **RevenueCat** (`purchases_flutter ^8.0.0`) for subscription management:

- **Entitlement:** `premium`
- **Products:** `simon_premium_monthly` ($9.99/mo), `simon_premium_yearly` ($59.99/yr)
- Paywall with feature highlights and plan selection
- Restore purchases support
- Graceful fallback when API keys are not configured

### Setup

1. Create a RevenueCat project at [app.revenuecat.com](https://app.revenuecat.com)
2. Configure your App Store / Play Store products
3. Replace API keys in `lib/core/services/revenuecat_service.dart`:
   ```dart
   static const String appleApiKey = 'appl_YOUR_KEY';
   static const String googleApiKey = 'goog_YOUR_KEY';
   ```

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build for iOS
flutter build ios --no-codesign

# Build for Android
flutter build appbundle
```

### Requirements
- Flutter 3.0+
- Dart 3.0+
- iOS 15+ / Android API 24+

## 🧪 Technical Highlights

- **State Management:** Flutter Riverpod
- **On-Device AI:** Rule-based CBT coaching engine (zero API dependencies)
- **Local Storage:** SharedPreferences for all user data
- **Animations:** Custom animations, glassmorphism, gradient effects
- **Typography:** Google Fonts (Outfit + Inter)
- **Dark Mode First:** Beautiful dark theme optimized for evening use

## 📱 Screenshots

The app features:
- Glassmorphic navigation bar with gradient active states
- Mood chart with weekly visualization
- AI coach chat interface with quick prompts
- Sleep story player with pulsing ambient animations
- Body scan with progressive region highlighting
- Swipeable affirmation cards with gradient backgrounds

## 🙏 Credits

Built with Flutter & RevenueCat for the RevenueCat Hackathon.

- Meditation content & therapeutic frameworks based on evidence-based CBT and mindfulness practices
- No external AI APIs required — all coaching logic runs on-device

---

**Simon** — Because everyone deserves a wellness companion in their pocket. 💜
