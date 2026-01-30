# Copilot Instructions for art_drop_finder

A Flutter app following clean architecture, managing art drops with location-based discovery, artist claims, and social media integration.

## Architecture Overview

**Clean Architecture Pattern** with strict dependency rules:
- **presentation** → **domain** ← **data** (unidirectional)
- **domain** is pure Dart (no Flutter imports, no external dependencies)
- **data** implements domain repository abstractions
- **core** holds framework-agnostic utilities

**Feature Structure** (`lib/features/<feature>/`):
```
data/datasources/      # Local/remote data access (SharedPreferences, Appwrite)
data/models/           # Data layer models with serialization
data/repositories/     # Repository implementations
domain/entities/       # Business logic models (immutable, copyWith)
domain/repositories/   # Abstract interfaces
domain/usecases/       # Business logic, extends UseCase<Return, Params>
presentation/pages/    # Full screens (MaterialApp children)
presentation/widgets/  # Reusable UI components
presentation/controllers/ # State management (ChangeNotifier)
```

Current features: **auth**, **drops** (main), **home**.

## Key Patterns & Conventions

### UseCase Pattern
Every domain feature delegates to `UseCase<ReturnType, ParamsType>` subclass:
```dart
// Domain layer
class CreateArtDrop extends UseCase<ArtDrop, CreateArtDropParams> {
  @override
  ArtDrop call(CreateArtDropParams params) => /* logic */
}

// Presentation layer
final usecase = CreateArtDrop(repository);
final result = usecase(CreateArtDropParams(...));
```
Use `NoParams` if no parameters needed.

### Models & Entities
- **Entities** (domain): immutable, include `copyWith()`, business logic only
- **Models** (data): add serialization (`toJson()`, `fromJson()`), may include API metadata
- Always trim user input in usecases (`title.trim()`)

### Controllers
Extend `ChangeNotifier` for state management. Initialize usecases in `App.initState()` and dispose in `App.dispose()`. Controllers are passed to pages and widgets.

### Data Persistence
Current: **SharedPreferences** for all local storage (via `ArtDropLocalDataSource`). No Firebase/Appwrite yet implemented despite dependency.

### Services (Infrastructure)
Located in `data/services/`:
- `SocialPublisher`: Posts to Facebook/Instagram (not yet implemented)
- `LocationService`: Geo-location queries (`geolocator` package)
- `ImageStorage`: Image handling (`image_picker`, `path_provider`)

## Development Commands

```bash
flutter pub get          # Fetch dependencies
flutter run              # Run on default device
flutter run -d <id>      # Run on specific device (find via `flutter devices`)
flutter test             # Run all tests
flutter analyze          # Lint check
flutter doctor           # Environment check
flutter clean            # Remove build artifacts
```

## Import Convention
Always use package imports:
```dart
import 'package:art_drop_finder/features/auth/domain/usecases/login_artist.dart';
import 'package:art_drop_finder/core/usecase/usecase.dart';
```

## File Naming
- **Files**: snake_case (`auth_controller.dart`)
- **Classes/Enums**: PascalCase (`AuthController`, `UserRole`)
- **Constants**: camelCase (`maxRetries = 3`)

## Theme & Material Design
- Single `MaterialApp` in [lib/app/app.dart](../lib/app/app.dart) (seed color: `Colors.indigo`, Material 3 enabled)
- Keep dialogs, input forms, and pages "simple in design and easy to read" (per requirements)
- All pages must be navigable from [lib/features/drops/presentation/pages/drops_home_page.dart](../lib/features/drops/presentation/pages/drops_home_page.dart)

## Key Dependencies
- `appwrite: 20.3.2` - Backend (set up but not active in code)
- `geolocator: ^14.0.2` - GPS/location
- `image_picker: ^1.1.2` - Camera/gallery access
- `path_provider: ^2.1.5` - File paths
- `shared_preferences: ^2.3.2` - Local key-value storage

## Testing Strategy
Use `flutter_test` (included). Tests should verify:
- UseCase logic (domain layer)
- Model serialization (data layer)
- Repository fallback behavior

## Common Issues
1. **Import errors**: Use full package paths, not relative imports
2. **const constructors**: Prefer `const` everywhere (especially in domain/core)
3. **Circular dependencies**: Keep domain pure and separate from presentation/data
4. **State not rebuilding**: Ensure `ChangeNotifier.notifyListeners()` called in controllers

## Next Steps for Features
When adding a new feature (e.g., `notifications`):
1. Create `lib/features/notifications/{data,domain,presentation}`
2. Define entity and abstract repository in domain
3. Implement repository in data (choose datasource: local/remote)
4. Create usecases for each action
5. Build controller extending `ChangeNotifier`
6. Connect page/widgets and inject controller in [lib/app/app.dart](../lib/app/app.dart)

# App Requirements

The App is designed according to the latest UI UX rules and material design principles. Care must be taken to ensure that all dialogue boxes, pages and input masks are very simple in design and easy for users to read and use.

# App Functionality

## Art Drop eintragen

The artist can log into the platform and enter a new art drop. To do this, they can add a description and location to the title, query their mobile phone, and upload a photo of the art drop and its surroundings. This location is kept secret until all art drop was found by a passer-by. For this the artist can also enter the number of drops stored at the location. 

After clicking the publish button, the art drop is published on a predefined Facebook group and in an Instagram message. The posts containing the images of this souroundings, the title and the description.

The artist can adjust the number of art drops still available and set it so that all art drops have been found.

## Art Drop beanspruchen

When a passer-by finds an Art Drop, they can scan the QR code attached to it and be taken to the Art Drop claim page. On this page, they can enter their name or nickname and press the claim button. After clicking the button, a message is posted to the relevant Facebook or Instagram groups. This post shows the art drop and the name of the person claiming it. The title is the art drop title and description. If all art drops have been claimed, this is also included in the message text. In this case, the message also contains a link to the Art Drop Display page.

## Art Drop anzeigen

This page contains all Artrops, whether they have been found or not, in a list. The Art Drops can be clicked on and a map appears on which they are displayed if they have all been found and claimed. If not all Art Drops have been found, the page displays the title, description and photos of the surroundings.

If all Art Drops have been found and claimed by passers-by, they will be displayed on the public map with their specific location. 