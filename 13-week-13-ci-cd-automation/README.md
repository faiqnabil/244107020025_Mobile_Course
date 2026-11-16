# CI/CD Automation – Week 13

## 🎯 Objective
Create a GitHub Actions workflow that automates the **format**, **static analysis**, **testing**, and **building** of a Flutter project, and publishes the generated **APK** and **AAB** as artifacts.

---

## 📋 Prerequisites
- A Flutter project located at the repository root.
- GitHub repository with **Actions** enabled.
- (Optional) A keystore for signing releases. Store it as a Base64‑encoded secret `KEYSTORE_BASE64` and its password as `KEYSTORE_PASSWORD`.

---

## 🛠️ Workflow Overview (`.github/workflows/flutter-ci.yml`)
| Step | Description |
|------|-------------|
| **Checkout** | Pull the repository code. |
| **Flutter Setup** | Install the stable Flutter SDK via `subosito/flutter-action`. |
| **Signing Setup** | Decode `KEYSTORE_BASE64` to `keystore.jks` (placeholder) and create `android/key.properties` with the password. |
| **Dependencies** | `flutter pub get`. |
| **Versioning** | If triggered by a tag, update `pubspec.yaml` with the tag version and a build number. |
| **Formatting** | `dart format --output=none --set-exit-if-changed .` (fails the job on format violations). |
| **Static Analysis** | `flutter analyze --fatal-infos`. |
| **Tests** | `flutter test --coverage`. |
| **Build APK & AAB** | `flutter build apk --release` and `flutter build appbundle --release`. |
| **Upload Artifacts** | Store `app-release.apk` and `app-release.aab` as GitHub Artifacts (7‑day retention). |
| **Draft Release** | Create a draft GitHub release (`v<run_number>`). |

---

## 🚀 How to Run
1. **Commit & push** the workflow file to the `main` branch.
2. Open the **Actions** tab on GitHub – the `Flutter CI` workflow will run automatically on pushes, pull‑requests, and manual dispatches.
3. Verify each step; any failure (format, analysis, or tests) will mark the job as failed.
4. After a successful run, download the generated APK/AAB from the **Artifacts** section.

---

## 🔑 Secrets & Security
- `KEYSTORE_BASE64` – Base64‑encoded keystore file (optional, required for signed releases).
- `KEYSTORE_PASSWORD` – Password for the keystore.
- `GITHUB_TOKEN` – Automatically provided; used for creating draft releases.

> **Important:** Never log secret values; the workflow only writes them to files used by the build process.

---

## 📦 Versioning
- The workflow detects a tag push (`refs/tags/vX.Y.Z`).
- It updates `pubspec.yaml` with `version: X.Y.Z+<run_number>`.
- Tag name is also used for the draft release name.

---

## 📋 Checklist after a Run
- [ ] All steps passed (format, analyze, tests, builds).
- [ ] APK and AAB artifacts are available for download.
- [ ] Draft release created with correct tag.
- [ ] Document the version, tests executed, and any security considerations.

---

## 🧐 Reflection Questions
- **What issues were caught automatically before merging?**
- **What information would you need to investigate a failed build?**
- **Which parts of the release still need manual approval or review?**

---

*This README was generated as part of the CI/CD automation practicum for week 13 of the Mobile Development course.*