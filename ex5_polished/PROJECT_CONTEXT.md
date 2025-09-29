# DayStream: Project Overview & Technical Documentation

## 1. Project Overview

**DayStream** is a modern, daily reflection mobile application built entirely with SwiftUI. It allows users to track their emotional state, energy levels, and daily activities through a polished and intuitive interface. The app focuses on providing insights through data visualization and encourages consistent self-reflection with guided prompts and dynamic feedback.

---

## 2. Architecture & Persistence

### MVVM (Model-View-ViewModel)
The application is structured using the **MVVM** architectural pattern to ensure a clean separation of concerns:
-   **Model**: Represents the data layer. In this project, the primary model is the `DailyEntry` class, managed by SwiftData.
-   **View**: The UI layer, composed of declarative SwiftUI views. Views are designed to be lightweight and reactive to state changes.
-   **ViewModel**: Acts as a bridge between the Model and the View. It handles business logic, data formatting, and user actions. `SettingsViewModel` is a prime example. The app also uses an `AppState` `ObservableObject` to manage global UI state like the onboarding flow.

### Persistence: SwiftData
-   **Core Framework**: Data persistence is handled by **SwiftData**.
-   **Setup**: The SwiftData container is injected into the environment in the main app entry point (`ex5_polishedApp.swift`) via the `.modelContainer(for: DailyEntry.self)` modifier.
-   **Custom Transformers**: To reliably store complex types like `[String]` and `[String: PromptRecord]`, custom `ValueTransformer` classes (`StringArrayTransformer`, `PromptRecordDictionaryTransformer`) are used. These are registered when the app launches and applied to the model properties using the `@Attribute(.transformable(by: ...))` macro.

---

## 3. Core Data Model: `DailyEntry`

The `DailyEntry` class is the heart of the app's data layer. Each instance represents a single day's reflection.

| Property              | Type                       | Description                                                                 |
| --------------------- | -------------------------- | --------------------------------------------------------------------------- |
| `date`                | `Date`                     | **Primary Key**. The start of the day for the entry. Marked as unique.      |
| `emotionScore`        | `Int`                      | User's emotional state score (1-10).                                        |
| `energyScore`         | `Int`                      | User's energy level score (1-10).                                           |
| `productivityScore`   | `Int`                      | User's productivity score (1-10).                                           |
| `stressScore`         | `Int`                      | User's stress level score (1-10).                                           |
| `satisfactionScore`   | `Int`                      | User's overall satisfaction score (1-10).                                   |
| `nutritionScore`      | `Int`                      | Contextual score for nutrition quality (1-10).                              |
| `sleepScore`          | `Int`                      | Contextual score for sleep quality (1-10).                                  |
| `exerciseScore`       | `Int`                      | Contextual score for exercise (1-10).                                       |
| `gratitudeScore`      | `Int`                      | Contextual score for gratitude practice (1-10).                             |
| `socialConnectionScore` | `Int`                    | Contextual score for social connection (1-10).                              |
| `influenceTags`       | `[String]`                 | A list of dynamically generated or user-selected tags describing the day.   |
| `journalText`         | `String`                   | An optional, free-form journal entry.                                       |
| `reflections`         | `[String: PromptRecord]`   | A dictionary storing answers to guided prompts, keyed by category.          |
| `isComplete`          | `Bool`                     | A flag set to `true` when the user completes their daily check-in.          |

---

## 4. Application Structure & Core Features

The app is built around a `TabView` with four main sections.

### Onboarding & App Entry
-   **`ex5_polishedApp.swift`**: The app's entry point. It registers the custom `ValueTransformer`s and sets up the SwiftData `.modelContainer`.
-   **`ContentView.swift`**: The root view. It manages the initial app state:
    1.  Shows a `SplashScreenView`.
    2.  Checks `isFirstLaunch` from the `AppState` environment object.
    3.  If `true`, it displays the `OnboardingView` to set notification preferences.
    4.  If `false`, it displays the main `MainTabView`.
-   **`MainTabView`**: This view is the central hub. It finds or creates the `DailyEntry` for the current day and passes it to the relevant tabs.

### Tab 1: Check-in (`DailyCheckInView`)
This is the primary action screen for the user.
-   **Score Sliders**: Five main sliders for Emotion, Energy, Productivity, Stress, and Satisfaction.
-   **Context Sliders**: A separate section with five sliders for contextual factors like Nutrition, Sleep, and Exercise.
-   **Suggested Tags (`InfluenceTaggerView`)**: A key feature where tags are dynamically suggested based on the user's slider inputs.
    -   **`TagGenerationService`**: A dedicated service that contains the logic for generating a list of candidate tags (e.g., "Rested", "Anxious", "Productive Deep Work").
    -   **`FlowLayout`**: A custom SwiftUI `Layout` is used to display the tags in a fluid, wrapping container that adapts to screen size.
    -   **Interaction**: Suggestions are unselected by default and update in real-time as sliders are adjusted. User-selected tags are preserved.

### Tab 2: Journal (`JournalPromptView`)
This tab offers deeper reflection.
-   **Mode Toggle**: A segmented picker allows switching between "Quick Journal" and "Guided Prompts".
-   **Quick Journal**: A simple `TextEditor` for free-form writing with a manual "Save" button.
-   **Guided Prompts**:
    -   Presents a checklist of reflection categories (e.g., "🌱 Personal Growth", "🙏 Gratitude & Positivity").
    -   Completed categories are marked with a checkmark.
    -   Tapping a category navigates to a `PromptDetailView` which presents a random prompt from that category and allows the user to save their answer.

### Tab 3: Insights (`InsightsView`)
This tab visualizes trends and history.
-   **Consistency Streak**: A motivational card showing the number of consecutive days the user has completed an entry.
-   **7-Day Trend Chart**: Uses the `Charts` framework to display a line chart of the average daily score over the last week.
-   **Recent History**: A list of the last 14 entries. Tapping an entry navigates to the `DailyEntryDetailView` for a full, read-only summary of that day's reflection.

### Tab 4: Settings (`SettingsView`)
Provides app customization and data management.
-   **Preferences**: Toggles for Haptic Feedback and Sound Effects.
-   **Notifications**: A `DatePicker` to modify the daily reminder time.
-   **Data Management**: A "Delete All Data" button, protected by a confirmation `alert` to prevent accidental data loss.

