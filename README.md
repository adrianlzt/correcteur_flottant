# Correcteur Flottant

Correcteur Flottant is a floating corrector app for Android. It allows you to select text in any application (or share it with the app) and get it corrected for grammar, spelling, and style using powerful Large Language Models (LLMs). The correction appears in a floating overlay, making it easy to review and use.

<p align="center"><img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="App Icon" width="128"/></p>

## Features

- Corrects text from any app using Android's native text selection menu or the share action.
- Displays corrections and explanations in a convenient floating overlay.
- Supports multiple LLM providers:
  - OpenAI (e.g., GPT-4o, GPT-3.5-turbo)
  - Google Gemini (e.g., Gemini 1.5 Flash)
  - Anthropic Claude (e.g., Claude 3 Haiku)
  - OpenRouter.ai (access to a wide variety of models)
- Customizable: Bring your own API key, choose your provider, and even specify a model.
- Get explanations for corrections in your preferred language.

## Installation

You can download and install the app using the APK file from the latest release.

1.  **Download the latest APK:**
    -   [**correcteur_flottant.apk**](https://github.com/adrianlzt/correcteur_flottant/releases/latest/download/correcteur_flottant.apk)
    -   Alternatively, go to the [Releases page](https://github.com/adrianlzt/correcteur_flottant/releases) to find all versions.

2.  **Enable installation from unknown sources:**
    -   On your Android device, go to `Settings > Security` (or `Settings > Apps > Special app access > Install unknown apps`).
    -   Allow your browser or file manager to install apps from unknown sources. This step is necessary because the app is not on the Google Play Store.

3.  **Install the APK:**
    -   Open the downloaded `.apk` file from your browser's downloads or a file manager.
    -   Follow the on-screen prompts to install the application.

## How to Use

After installing the app:

1.  Open the app and go to the **Settings** screen (top-right gear icon).
2.  Choose your preferred **LLM Provider** (e.g., OpenRouter.ai).
3.  Enter your **API key** for that provider.
4.  (Optional) Specify a **Model Name** if you want to use one other than the default.
5.  (Optional) Set the **Explanation Language**.
6.  Save your settings.
7.  Now, go to any other app (e.g., a messaging app, a browser, a note-taking app).
8.  There are two ways to get your text corrected:
    -   **Using the text selection menu:** Select the text, tap the three dots (overflow menu) in the context menu, and choose **Correcteur Flottant**.
    -   **Using the share menu:** Select the text, tap "Share", and choose **Correcteur Flottant** from the app list.
9.  The app will launch a floating window with the corrected text and explanations.

## For Developers

This project is built with Flutter and is open to contributions.

### Project Structure

-   `lib/`: Main application code.
    -   `api/`: Adapters for different LLM APIs (`openai_adapter.dart`, `gemini_adapter.dart`, etc.).
    -   `screens/`: UI screens for the app (`settings_screen.dart`, etc.).
    -   `services/`: Core services like `llm_service.dart` (handles API logic) and `secure_storage_service.dart` (for API keys).
    -   `widgets/`: Reusable UI components like `correction_overlay.dart`.
    -   `main.dart`: The main entry point of the application.
-   `android/`: Native Android code, including the `MainActivity.kt` which handles the `ACTION_PROCESS_TEXT` intent.

### Getting Started for Development

1.  Clone the repository.
2.  Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
3.  Install dependencies: `flutter pub get`
4.  Run the app on an emulator or a physical Android device: `flutter run`

### How to Contribute

#### Adding a new LLM Provider

1.  Create a new `your_provider_adapter.dart` in `lib/api/` that implements the `LlmApiAdapter` abstract class.
2.  Implement the `getCorrection` method to call the new provider's API.
3.  Add your provider to the `LlmProvider` enum in `lib/services/llm_service.dart`.
4.  Add a case for your new provider in the `_getAdapter` method in `lib/services/llm_service.dart` and `lib/screens/settings_screen.dart`.
5.  (If needed) Update the settings screen to accommodate any specific requirements for your provider.

#### Bug Fixes & Feature Enhancements

1.  Fork the repository.
2.  Create a new branch for your feature or fix.
3.  Make your changes.
4.  Submit a pull request with a clear description of your changes.
