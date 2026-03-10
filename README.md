# MedCare

MedCare is a Flutter application for medication reminders, caregiver coordination, health tracking, and emergency assistance.

## Cross-platform URL

This project can be deployed as a Flutter web app and opened from any modern browser on:

- Windows
- macOS
- iPhone and iPad
- Android phones and tablets

Once GitHub Pages is enabled for this repository, the app URL will be:

https://sandhya-sridar.github.io/medcare/

## Deployment

This repository includes a GitHub Actions workflow that automatically builds and deploys the Flutter web app whenever code is pushed to `main`.

### One-time GitHub setup

1. Open the repository on GitHub.
2. Go to `Settings` > `Pages`.
3. Set the source to `GitHub Actions`.
4. Push this workflow to `main`.
5. Wait for the `Deploy Flutter Web` workflow to finish.

After the workflow completes, GitHub Pages will serve the app at the URL above.

## Local development

Install dependencies:

```bash
flutter pub get
```

Run locally in Chrome:

```bash
flutter run -d chrome
```

Create a production web build:

```bash
flutter build web --release
```

## Notes

- This deployment path publishes the web app, not native App Store or Play Store binaries.
- If you later want installable native builds, you will still create separate Android, iOS, Windows, and macOS releases.
- The current app builds successfully for the web target.
