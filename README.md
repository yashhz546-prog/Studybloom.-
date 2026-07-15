# StudyBloom 🌸

A premium, minimalist daily discipline tracker for school students — homework,
physical activity, self-study, and phone usage, distilled into a single daily
score out of 100.

## What's included

```
lib/
  main.dart                        # App bootstrap, Hive + notification init
  theme/app_theme.dart             # Baby pink / cream palette, Montserrat type
  models/daily_entry.dart          # DailyEntry model + hand-written Hive adapter
  services/
    storage_service.dart           # Hive box wrapper (local, offline-first)
    score_calculator.dart          # Exact marking scheme from the spec
    notification_service.dart      # Evening "did you log today?" reminder
    pdf_export_service.dart        # Monthly progress → shareable PDF
  providers/daily_entry_provider.dart  # State management (Provider/ChangeNotifier)
  screens/
    home_screen.dart               # Greeting, progress ring, 4 sections, CTA
    result_screen.dart             # Score ring, feedback, confetti >90
    history_screen.dart            # Calendar, streak, averages, best day
  widgets/
    progress_ring.dart             # Reusable animated circular ring
    section_card.dart              # Shared rounded "premium card" shell
    homework_section.dart          # Checklist with animated checks
    physical_activity_section.dart # Radio-button selector
    numeric_input_section.dart     # Minutes input with live "≈ Xh Ym" helper
pubspec.yaml
```

## How the score is calculated

- **Homework — 30 pts**: `floor(completed / 11 × 30)` (matches the spec's
  worked examples: 11→30, 10→27, 9→24).
- **Self Study — 40 pts**: piecewise-linear between 0→0, 30→10, 60→20, 90→25,
  120→30, 150→35, 180+→40.
- **Physical Activity — 15 pts**: 30 min→5, 1 hr→10, 2 hr→13, 3+ hr→15.
- **Phone Usage — 15 pts**: ≤30 min→15, 60→12, 90→9, 120→6, 180+→0
  (piecewise-linear between anchors).

All logic lives in `lib/services/score_calculator.dart` if you want to retune
any of the weights later.

## Setup (you'll need the Flutter SDK installed locally — this was written
## in an environment without Flutter/network access, so it hasn't been
## run through `flutter pub get` or a real build yet)

1. Install Flutter (3.22+) and Android Studio / an Android device or
   emulator running **Android 8.0 (API 26)** or newer.
2. Scaffold the native Android/iOS shells (this project only ships the
   `lib/` Dart code + `pubspec.yaml`, since those don't require the SDK to
   write, but the native wrapper does need `flutter create` to generate
   correctly for your machine):
   ```bash
   flutter create --project-name studybloom --org com.example .
   ```
   This will add `android/`, `ios/`, etc. **without** overwriting the
   `lib/` folder or `pubspec.yaml` already in this project — if it prompts
   to overwrite `pubspec.yaml`, choose "no" (or re-copy the one included
   here afterward).
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. In `android/app/build.gradle` (or `build.gradle.kts`), set:
   ```
   minSdk = 26
   ```
5. Run it:
   ```bash
   flutter run
   ```

## Getting an installable APK without a computer (GitHub Actions)

This project includes `.github/workflows/build-apk.yml`, which builds a
release APK in the cloud every time you push code. All you need is a free
GitHub account and a browser:

1. Go to [github.com](https://github.com) → sign up/log in → click **+** →
   **New repository**. Name it `studybloom`, keep it **Public** (needed for
   free Actions minutes), click **Create repository**.
2. On the new repo's page, click **"uploading an existing file"** (or the
   `Add file → Upload files` button).
3. Unzip `studybloom.zip` on your phone or computer, then drag the
   **contents** of the `studybloom` folder (not the folder itself — `lib/`,
   `pubspec.yaml`, `.github/`, `README.md`, etc.) into the upload box.
   Commit the changes.
4. Click the **Actions** tab at the top of the repo. You should see a
   workflow run start automatically ("Build APK"). It takes about 3–5
   minutes.
5. Once it finishes (green checkmark), click into that run, scroll to
   **Artifacts**, and download **studybloom-apk** — it's a zip containing
   `app-release.apk`.
6. Transfer that APK to your phone (email it to yourself, upload to Google
   Drive, etc.), tap it, and allow **"install from unknown sources"** if
   prompted. That's it — installed.

Every time you (or I) push updated code to that repo, a fresh APK builds
automatically — no computer or Flutter install required on your end.



- **Midnight reset**: handled naturally — every day gets its own storage key
  (`yyyy-MM-dd`), so a new day always starts blank while every previous day
  stays in history untouched.
- **Evening reminder**: currently fires as soon as the app detects today is
  incomplete (simple, no-timezone-setup version). To make it fire at an exact
  clock time daily, add the `timezone` package and switch
  `notification_service.dart` from `.show()` to `.zonedSchedule()` with a
  daily-repeat match — happy to wire that up if you want it.
- **PDF export**: available from the History screen's PDF icon; opens the
  system share/print sheet with a monthly table of scores.
- App icon / splash screen assets aren't included — drop your artwork into
  `android/app/src/main/res/` (or use `flutter_launcher_icons`) whenever
  you're ready.

## Design tokens

| Token | Value |
|---|---|
| Primary (Baby Pink) | `#F8C8DC` |
| Secondary (Soft Blush) | `#FFDCE8` |
| Accent (Rose Pink) | `#F5A9C5` |
| Background (Warm Cream) | `#FFF9F2` |
| Font | Montserrat (via `google_fonts`) |
| Corner radius | 16–24px |
