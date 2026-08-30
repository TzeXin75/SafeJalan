# SafeJalan - Native Flutter Version

This version is rebuilt with native Flutter widgets following **BMIT2073 Practical Flutter 202605**. It does not use WebView, React, or TypeScript.

## Requirements

- Flutter stable with Dart 3.8 or later
- Android Studio with the Flutter and Dart plugins
- Android SDK supported by your installed Flutter version
- Android NDK `28.2.13676358` (install it from SDK Manager > SDK Tools)
- Android 7.0 / API 24 or newer device
- Gradle 8.14.3, Android Gradle Plugin 8.11.1, and Kotlin 2.2.20

## Run in Android Studio

1. Install Flutter from `https://docs.flutter.dev/get-started/install/windows/mobile` and run `flutter doctor`.
2. Install the **Flutter** plugin in Android Studio. The Dart plugin is installed with it.
3. Open this `SafeJalanNativeFlutter` folder, not only the `android` subfolder.
4. In the terminal, run `flutter pub get`.
5. Start an emulator from Device Manager or connect an Android phone with USB debugging.
6. Select the device and run `lib/main.dart`.

## Command line

```powershell
flutter doctor
flutter pub get
flutter run
```

Build an APK with:

```powershell
flutter build apk --debug
```

The APK will be written to `build/app/outputs/flutter-apk/app-debug.apk`.

## Practical methods used

- Practical 3: controllers, `StatefulWidget`, `setState`, inputs and outputs.
- Practical 4: `Navigator`, `MaterialPageRoute`, and passing report objects.
- Practical 5: Provider, `ChangeNotifier` and `notifyListeners`.
- Practical 6: `Form`, validators, dropdowns and choice chips.
- Practical 9: SQLite for accounts, login state and offline application data.
- Practical 8: image_picker, path_provider and `Image.file`.
- Practical 9: SQLite CRUD for road reports, connectivity reports and safety announcements.
- Practical 11: Supabase remote CRUD and synchronization.
- Practical 12: flutter_map and OpenStreetMap markers.
- Practical 13: location permissions and device GPS.

## Structure

- `lib/models` - road report, connectivity, announcement and account models.
- `lib/providers` - shared application state.
- `lib/services` - SQLite and Supabase database operations.
- `lib/repositories` - local-first report synchronization.
- `lib/screens/auth` - validated login and registration.
- `lib/screens/user` - map, reporting, announcements, connectivity, leaderboard and profile.
- `lib/screens/admin` - dashboard, user/report/connectivity/announcement management, heatmap and statistics.
- `lib/widgets` - reusable Flutter widgets.

Authentication is currently a classroom prototype. Road reports use SQLite as the offline local database and Supabase as the optional remote database.

## Configure Supabase remote database

1. Create a Supabase project.
2. Open **SQL Editor** and run `supabase/schema.sql` once.
3. Open `lib/main.dart` and paste the client-safe **Legacy anon key** into `supabaseKey`.
4. Run the app normally:

```powershell
flutter pub get
flutter run
```

If `supabaseKey` is empty, SafeJalan continues to work with SQLite only. The Legacy anon key is intended for client apps. Never put an `sb_secret_...` or `service_role` key in this Flutter project because an APK cannot keep it secret.

## Database synchronization

- Create/update/delete always writes to SQLite first.
- Unsynced records are marked `pending`.
- When Supabase is configured, pending records upload automatically.
- On startup and after CRUD operations, remote rows are downloaded into SQLite.
- Verification rows are downloaded so a user's Still Exists state is restored on another device.
- Connectivity reports and safety announcements follow the same local-first sync flow.
- Failed remote requests stay safely in SQLite and retry on the next sync.
- Profile shows whether the app is using SQLite only or SQLite + Supabase, and includes a manual Sync button.

## Fresh data and leaderboard

- The app starts without sample reports, users, connectivity reports, rankings, statistics, or badges.
- Version 2 performs a one-time reset of older local SQLite reports and SharedPreferences data.
- A user joins the leaderboard automatically after submitting the first report.
- Points are calculated automatically: 80 points per report plus 5 points per verification vote.
- The current local prototype has one user account. A multi-user leaderboard requires a shared backend such as Supabase.
