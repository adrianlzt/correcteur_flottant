## [v1.1.0] - 2025-07-10

### Added
*   **Text Correction & LLM:**
    *   Support for Android text sharing via `ACTION_SEND` intent.
    *   Configurable default LLM model and hint.
    *   OpenRouter API key help icon.
    *   General language tutor support for any language, replacing the dropdown with a text field.
    *   Explanation language setting and adaptive prompts.
    *   Button to test LLM provider configuration.
    *   Set OpenRouter with the R1 model as the default LLM provider.
    *   Custom separator for OpenRouter LLM responses.
*   **User Interface:**
    *   New app icon.
    *   App now appears in recent apps.
    *   Top-right close button to the overlay; removed redundant ones.
    *   Ability to discard the overlay by dragging it to the top.
*   **Developer Experience:**
    *   Configured `flutter analyze` pre-commit hook.

### Changed
*   Renamed latest release asset and updated README.
*   Updated application bundle identifier and company information.

### Fixed
*   **Application Stability:**
    *   Ensured `isPermissionGranted` and `initialText` are non-nullable and simplified related checks.
    *   Resolved circular dependency and `implements_non_class` errors.
    *   Resolved general version-related issues.
    *   App now closes after handling a shared text intent.
    *   Prevented the app from opening when launching the overlay.
*   **LLM Integration:**
    *   Corrected OpenAI adapter instantiation typo.
    *   Defined and used a system prompt for the OpenAI adapter.
    *   Removed unreachable default case in `llm_service.dart`.
    *   Handled non-JSON LLM responses and removed debug logs.
    *   Prevented OpenRouter JSON truncation.
    *   Enabled JSON mode for OpenRouter API and fixed `FormatException` by adding `max_tokens`.
*   **Overlay & UI:**
    *   Corrected mismatched parentheses in the correction overlay.
    *   Disabled overlay dragging to prevent scroll interference.
    *   Enabled copy button and overlay scrolling.
    *   Made the correction overlay scrollable.
    *   Replaced `FlutterOverlayWindow.matchParent` with `-1` to resolve build error.
    *   Added internet permission and expanded the overlay window.
    *   Enabled overlay window by adding foreground service configuration.
    *   Added missing `TransparentTheme` style for Android build.
    *   Prevented UI flash by passing process text directly.
    *   Added Android intent filter for text selection toolbar.
*   **Build & Environment:**
    *   Aligned Android JVM and Kotlin targets (Java 17, Java 11, Kotlin 1.8) across projects.
    *   Re-added missing Java imports for Gradle build scripts.

### Refactored
*   Standardized LLM adapter interfaces, system prompt generation, and unified API response parsing.
*   Converted the overlay to a transient activity for clipboard support.
*   Used `super` parameters in various constructors.
*   Replaced `print` with `debugPrint` for better logging.
*   Made the app launch seamlessly for the text selection overlay.

### CI/CD
*   Introduced GitHub Actions for Flutter CI/CD.
*   Matched APK version with Git tags and workflow runs.
*   Restricted build steps to tag pushes.
*   Formatted Flutter CI workflow.
*   Renamed release APK to include the version tag.
*   Granted contents write permission in the workflow.
*   Automated GitHub release uploads.
*   Ensured keystore and `key.properties` creation in CI for Android builds.

### Documentation
*   Added explanation for text correction via the share menu.
*   Added app launcher icon to README.
*   Updated README with features, installation, usage, and a development guide.
*   Added APK installation instructions and the latest download link.

### Chore
*   Removed unsupported platform configuration and dependencies.
*   Removed `flutter_overlay_window` dependency.
*   Removed unused test directory.
*   Added logging for OpenRouter API response and errors.
*   Removed redundant build script imports.

### Style
*   Used native dimming for process text overlay.
*   Addressed lint warnings in `main.dart`.
