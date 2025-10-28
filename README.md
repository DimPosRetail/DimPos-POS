# DimPos Store

A Flutter-based Point-of-Sale (POS) application designed for selling dimsum. Built using a feature-first architecture, Riverpod for state management with an observable pattern, and code generation for boilerplate reduction.

---

## 🗂️ Project Structure

```
lib/
├── constants/           # Application-wide constants (assets, colors, etc.)
├── enums/               # Shared enum definitions
├── environment/         # Environment configurations (dev, prod)
├── extensions/          # Dart & Flutter extension methods
├── features/            # Feature-first modules
│   ├── authentication/  # Login, signup, auth logic
│   ├── common/          # Shared UI components, utilities
│   ├── home/            # Home/dashboard feature
│   ├── management/      # Product & order management
│   ├── membership/      # Customer membership feature
│   ├── onboarding/      # Onboarding flow
│   ├── product/         # Dimsum product feature
│   │   ├── models/      # Data models (with `freezed`/json_serializable)
│   │   ├── repositories/# Data layer (API, local storage)
│   │   └── ui/          # Presentation layer
│   │       ├── state/   # Riverpod state providers
│   │       ├── view_models/ # ViewModels (notifiers)
│   │       └── widgets/ # Reusable widgets & screens
│   └── setting/         # App settings & preferences
├── routing/             # go_router configuration
├── theme/               # App theming & styles
├── utils/               # Helper functions & classes
└── main.dart            # App entry point
```

---

## 🚀 Features

- **Feature-First Architecture**
  Modular structure that groups code by feature for maintainability and scalability.

- **Riverpod + Observable Pattern**
  State management with Riverpod's providers & notifiers, following an observable pattern.

- **Code Generation**

  - `freezed` & `json_serializable` for immutable models and JSON parsing.
  - Generated Riverpod providers & data classes.

- **Routing**
  `go_router` for declarative, type-safe routing.

- **Theming**
  Material 3 with seeded color schemes.

- **Native Splash**
  `flutter_native_splash` for customizable splash screen.

- **Launcher Icons**
  `flutter_launcher_icons` for app icons on both Android & iOS.

---

## 📦 Getting Started

### 1. Prerequisites

- Flutter SDK ≥ 3.x
- Dart SDK ≥ 2.17
- A code editor (VS Code, Android Studio)

### 2. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
cd REPO_NAME
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Add environment variables

Create a `.env` file in the project root with your API configuration:

```bash
# .env
API_BASE_URL=https://your.api.endpoint
```

> 🔒 **Security**
> Ensure you add `.env` to your `.gitignore` to avoid committing sensitive information.

### 5. Generate code

Whenever you add or modify model classes, providers, or annotations, run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> 💡 **Development mode**
> To keep code generation running and automatically rebuild on changes, use:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 6. Update splash screen (if needed)

If you change splash assets or colors, re-run:

```bash
dart run flutter_native_splash:create
```

### 7. Update launcher icons (if needed)

After updating icon assets, run:

```bash
dart run flutter_launcher_icons
```

### 8. Run the app

```bash
flutter run
```

---

## 🎨 Theming & Styling

- Uses a `ThemeMode` provider to toggle light/dark.
- Material 3 seeded color schemes via `ColorScheme.fromSeed(...)`.
- Custom text styles with `GoogleFonts` and a centralized `AppTheme` class.

---

## 🤝 Contributing

Contributions are welcome! Please open issues or pull requests for bug fixes, enhancements, or new features.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Fix error

When ever you see the error after using "dart run build_runner watch --delete-conflicting-outputs" like:
[The argument type 'Element' can't be assigned to the parameter type 'Element2'.]
[The argument type 'Map<Element, LibraryElement?>?' can't be assigned to the parameter type 'Map<Element2, LibraryElement2?>?'.]
Please modify the pubspec.yaml the dependency_overrides:
dependency_overrides:
analyzer: 7.3.0
analyzer_plugin: 0.12.0
