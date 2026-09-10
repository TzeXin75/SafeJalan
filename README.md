# SafeJalan

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
3. Open the `SafeJalan` project folder, not only the `android` subfolder.
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
- Practical 8: image_picker, path_provider and `Image.file`.
- Practical 9: SQLite CRUD for accounts, login state, road reports, connectivity reports, announcements, notifications and offline application data.
- Practical 11: Supabase remote CRUD and synchronization.
- Practical 12: flutter_map and OpenStreetMap markers.
- Practical 13: location permissions and device GPS.

## Structure

- `lib/models` - road reports, connectivity reports, announcements, notifications, leaderboard entries and account models.
- `lib/providers` - shared application state, business logic and synchronization coordination.
- `lib/services` - SQLite database and Supabase remote operations.
- `lib/repositories` - local-first road report synchronization.
- `lib/auth` - login, registration and password recovery.
- `lib/user` - map, reporting, notifications, connectivity, leaderboard and profile features.
- `lib/admin` - dashboard, user/report/connectivity/announcement management, heatmap and statistics.
- `lib/widgets` - reusable Flutter widgets and stored-image handling.
- `lib/schema.sql` - Supabase database schema and policies.

Authentication follows the classroom offline-first approach and does not use Supabase Auth. Account data is stored locally in SQLite and synchronized bidirectionally with the Supabase `user_profiles` table when internet access is available.

## Configure Supabase remote database

1. Create a Supabase project.
2. Open **SQL Editor** and run `lib/schema.sql` once.
3. Open `lib/main.dart` and paste the client-safe **Legacy anon key** into `supabaseKey`.
4. Enable Realtime for the following tables in the `supabase_realtime` publication:

```text
road_reports
report_verifications
safety_announcements
user_notifications
connectivity_reports
user_profiles
```

For a new Supabase project, run these statements once in **SQL Editor**:

```sql
alter publication supabase_realtime add table public.road_reports;
alter publication supabase_realtime add table public.report_verifications;
alter publication supabase_realtime add table public.safety_announcements;
alter publication supabase_realtime add table public.user_notifications;
alter publication supabase_realtime add table public.connectivity_reports;
alter publication supabase_realtime add table public.user_profiles;
```

5. Run the app normally:

```powershell
flutter pub get
flutter run
```

If `supabaseKey` is empty, SafeJalan continues to work with SQLite only. Use a client-safe Legacy anon/publishable key. Never put an `sb_secret_...` or `service_role` key in this Flutter project because an APK cannot keep it secret.

The schema creates the public `safejalan-images` Storage bucket. When using an anon/publishable key, configure suitable `storage.objects` policies in **Storage > Policies** so the app can upload and read report images and profile avatars. The custom account system in this classroom prototype is not intended to replace production authentication and authorization.

## Database synchronization

- Create/update/delete always writes to SQLite first.
- Unsynced records are marked `pending`.
- When Supabase is configured, pending records upload automatically.
- On startup and after CRUD operations, remote rows are downloaded into SQLite.
- Supabase Realtime listens for report, verification, announcement, notification, connectivity and user-profile changes, then refreshes the corresponding SQLite data and UI.
- Returning to the foreground and reconnecting to the internet trigger a full catch-up synchronization for events missed while the app was inactive or offline.
- Verification rows are downloaded so a user's Still Exists state is restored on another device.
- Connectivity reports and safety announcements follow the same local-first sync flow.
- Registration, profile edits, password changes, role changes and deactivation use the same pending/synced flow.
- With internet, login checks Supabase and refreshes SQLite. Without internet, login checks SQLite.
- When connectivity returns, pending SQLite user data is uploaded and the latest Supabase profiles are downloaded.
- Failed remote requests stay safely in SQLite and retry on the next sync.
- Synchronization runs automatically; the Profile page does not require a manual Sync button.

## Fresh data and leaderboard

- The app starts without sample road reports or connectivity reports. Four classroom administrator accounts and bundled comparison statistics are provided.
- A user joins the leaderboard automatically after submitting the first report.
- Points are calculated automatically: 80 points per report plus 5 points per verification vote.
- The leaderboard combines synchronized Supabase profiles with locally available reports.
