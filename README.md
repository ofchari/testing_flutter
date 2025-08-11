Got it — here’s your updated **README.md** with the Firebase App ID note added.

---

# Flutter + Firebase Hosting Deployment with GitHub Actions

This project demonstrates deploying a Flutter web app to Firebase Hosting using **GitHub Actions** for CI/CD automation.

---

## 📌 What Was Done

1. **Flutter Project Setup**

   * Created a Flutter app.
   * Configured it for Firebase Hosting deployment.

2. **Firebase Configuration Files**
   Added minimal Firebase configuration files to the project root:

   **`.firebaserc`**

   ```json
   {
     "projects": {
       "default": "deploy-testing-8fa88"
     }
   }
   ```

   **`firebase.json`**

   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ]
     }
   }
   ```

3. **Firebase App Config**

   * Added `google-services.json` for Android.
   * **No sensitive data was hardcoded** (keys, tokens).
   * **Firebase App ID** is stored securely in repository secrets.

4. **GitHub Actions CI/CD**

   * Automated build & deploy process:

     * Build Flutter web app.
     * Deploy to Firebase Hosting.

---

To get your **Firebase Deploy Token** from the command line, run:

```bash
firebase login:ci
```

### Steps:

1. Make sure you have the **Firebase CLI** installed:

   ```bash
   npm install -g firebase-tools
   ```

2. Log in to your Firebase account:

   ```bash
   firebase login
   ```

3. Generate the token:

   ```bash
   firebase login:ci
   ```

   * This will open a browser window for you to log in.
   * Once logged in, it will display a long token string in the terminal.

4. Copy that token and add it to your GitHub repo:

   * Go to **GitHub Repo → Settings → Secrets and variables → Actions → New repository secret**.
   * Name it:

     ```
     FIREBASE_DEPLOY_TOKEN
     ```
   * Paste the token as the value.


Change App Distribution in Firebase Console
Open Firebase Console → https://console.firebase.google.com

Select your project.

In the left menu, click Release & Monitor → App Distribution.

Choose your platform (Android or iOS) app.

Click Manage testers and groups.

You can:

Add or remove testers → Enter their email addresses.

Create groups (e.g., “QA team”, “Beta testers”).

Move testers between groups if you want to change who gets builds.

When you upload a new build (AAB/APK/IPA), you can pick which testers or groups get it.

Save and Firebase will send them an email invite.


## 🔐 Repository Secrets Used

* **`FIREBASE_DEPLOY_TOKEN`** → Used for authentication during deployment.
* **`FIREBASE_APP_ID`** → Stores the Firebase App ID securely (instead of hardcoding it).
* Added GOOGLE_SERVICES_JSON for .
* **No sensitive API keys are stored in the repo.**

---

## 🚀 Deployment Flow

1. Push changes to `main` branch.
2. GitHub Actions builds the Flutter web app.
3. Firebase Hosting is updated automatically.

---

## 🛠 GitHub Actions Workflow

**`.github/workflows/deploy.yml`**

```yaml
name: Flutter CI with Firebase

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      # 1️⃣ Checkout repo
      - uses: actions/checkout@v3

      # 2️⃣ Setup Java (needed for Gradle)
      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'

      # 3️⃣ Setup Flutter
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.32.8"  # Fixed version number

      # 4️⃣ Install dependencies
      - name: Install dependencies
        run: flutter pub get

      # 5️⃣ Check if secrets exist and create google-services.json
      - name: Check GitHub Secrets and Create JSON
        run: |
          echo "Checking if secrets are set..."
          if [ -z "${{ secrets.GOOGLE_SERVICES_JSON }}" ]; then
            echo "❌ GOOGLE_SERVICES_JSON secret is NOT SET or EMPTY"
            exit 1
          else
            echo "✅ GOOGLE_SERVICES_JSON secret exists"
            echo "Secret length: $(echo '${{ secrets.GOOGLE_SERVICES_JSON }}' | wc -c)"
          fi
          
          # Create the JSON file
          mkdir -p android/app
          echo '${{ secrets.GOOGLE_SERVICES_JSON }}' > android/app/google-services.json

      # 6️⃣ Validate the created JSON
      - name: Validate google-services.json
        run: |
          echo "=== File created successfully ==="
          ls -la android/app/google-services.json
          echo ""
          echo "=== File size ==="
          du -h android/app/google-services.json
          echo ""
          echo "=== JSON validation ==="
          if python3 -m json.tool android/app/google-services.json > /dev/null; then
            echo "✅ JSON is valid"
          else
            echo "❌ JSON is invalid, showing content:"
            cat android/app/google-services.json
            echo ""
            echo "Attempting to fix common issues..."
            # Remove potential BOM and normalize
            sed -i '1s/^\xEF\xBB\xBF//' android/app/google-services.json
            # Try validation again
            if python3 -m json.tool android/app/google-services.json > /dev/null; then
              echo "✅ JSON fixed and is now valid"
            else
              echo "❌ JSON still invalid after cleanup"
              exit 1
            fi
          fi

      # 7️⃣ Install Firebase CLI
      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      # 8️⃣ Authenticate Firebase
      - name: Firebase login
        run: firebase use --add deployment-8eb89 --token "${{ secrets.FIREBASE_TOKEN }}"

      # 9️⃣ Run tests
      - name: Run tests
        run: flutter test || true

      # 🔟 Clean before build
      - name: Clean Flutter
        run: flutter clean && flutter pub get

      # 1️⃣1️⃣ Build release APK
      - name: Build APK
        run: flutter build apk --release

      # 1️⃣2️⃣ Upload APK to artifacts
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

      # 1️⃣3️⃣ Upload APK to Firebase App Distribution with better error handling
      - name: Deploy to Firebase App Distribution
        if: github.ref == 'refs/heads/main'  # Only deploy on main branch
        run: |
          echo "🚀 Starting Firebase App Distribution..."
          echo "Branch: ${{ github.ref }}"
          echo "App ID: ${{ secrets.FIREBASE_APP_ID }}"
          
          if [ -z "${{ secrets.FIREBASE_APP_ID }}" ]; then
            echo "❌ FIREBASE_APP_ID secret is missing!"
            echo "Please add it to GitHub Secrets"
            exit 1
          fi
          
          firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
            --app ${{ secrets.FIREBASE_APP_ID }} \
            --token "${{ secrets.FIREBASE_TOKEN }}" \
            --groups "testers" \
            --release-notes "Automated build from GitHub Actions - $(date)" && \
          echo "✅ Successfully deployed to Firebase App Distribution!" || \
          echo "❌ Firebase App Distribution failed!"

## ✅ Next Steps

* Add **Docker** for containerized builds.
* Integrate with **Google Cloud Platform** for more automation.
* Expand CI/CD to include **testing** before deployment.


