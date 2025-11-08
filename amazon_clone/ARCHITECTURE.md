# Clean Architecture Refactoring

This document describes the Clean Architecture implementation for the Amazon Clone app.

## Architecture Overview

The project follows **Clean Architecture** principles with **feature-first** organization, using **Riverpod** for state management and **easy_localization** for internationalization.

## Project Structure

```
lib/
├── core/                          # Shared/common code
│   ├── error/                     # Error handling, failures
│   │   └── failures.dart
│   ├── network/                   # Network utilities
│   │   └── network_info.dart
│   └── utils/                     # Utility functions
│       └── result.dart            # Result type for error handling
├── features/                      # All app features
│   ├── auth/                     # Authentication feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   ├── data/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       └── providers/
│   ├── product/                  # Product feature
│   ├── cart/                     # Shopping cart feature
│   ├── category/                 # Category feature
│   ├── user/                     # User profile feature
│   └── search/                   # Search feature
├── screens/                      # UI screens (to be refactored)
├── widgets/                      # Reusable widgets
└── constants/                   # App constants
```

## Architecture Layers

### 1. Domain Layer
- **Entities**: Pure business objects with no dependencies
- **Repository Interfaces**: Abstract contracts defining data operations
- **No dependencies on other layers**

### 2. Data Layer
- **Models**: Data transfer objects that extend entities
- **Data Sources**: Interfaces and implementations for data fetching (JSON mock data)
- **Repository Implementations**: Concrete implementations of domain repositories
- **Depends only on Domain layer**

### 3. Presentation Layer
- **Providers**: Riverpod providers for state management
- **Screens**: UI components (ConsumerWidget/ConsumerStatefulWidget)
- **Widgets**: Feature-specific UI components
- **Depends on Domain layer (via repositories)**

## SOLID Principles

### Single Responsibility Principle (SRP)
- Each class has a single, well-defined responsibility
- Entities represent business objects
- Repositories handle data operations
- Providers manage state

### Open/Closed Principle (OCP)
- Repository interfaces allow extension without modification
- New data sources can be added by implementing interfaces

### Liskov Substitution Principle (LSP)
- Models extend entities and can be used interchangeably
- Repository implementations can be swapped

### Interface Segregation Principle (ISP)
- Small, focused repository interfaces
- Clients depend only on methods they use

### Dependency Inversion Principle (DIP)
- High-level modules (domain) don't depend on low-level modules (data)
- Both depend on abstractions (repository interfaces)
- Dependency injection via Riverpod providers

## State Management with Riverpod

- **Providers**: Define data sources and business logic
- **StateNotifier**: For complex state management (e.g., Cart)
- **FutureProvider**: For async data fetching
- **Provider.family**: For parameterized providers

## Error Handling

- **Result<T>**: Functional error handling with Success/Error types
- **Failure classes**: Specific error types (ServerFailure, NetworkFailure, etc.)
- **No exceptions**: Errors are handled through Result types

## Mock Data

All data sources use JSON files in `assets/data/`:
- `products.json`: Product data
- `categories.json`: Category data
- `users.json`: User data

## Localization

Using `easy_localization` with:
- English (`en.json`)
- Arabic (`ar.json`)

Translation files are in `assets/translations/`.

## Key Features

1. **No GetIt**: Dependency injection handled by Riverpod
2. **No Use Cases**: Business logic in repositories (as per requirements)
3. **Feature-First**: Each feature is self-contained
4. **Clean Architecture**: Strict layer separation
5. **SOLID Principles**: Applied throughout
6. **Mock Data**: JSON-based data sources
7. **Localization**: English and Arabic support

## Migration Notes

Screens in `lib/screens/` need to be refactored to:
1. Use Riverpod providers instead of Provider/ChangeNotifier
2. Use `ConsumerWidget` or `ConsumerStatefulWidget`
3. Access providers via `ref.watch()` or `ref.read()`
4. Use localization strings via `.tr()` extension
5. Handle Result types for error states

## Example Usage

### Using a Provider in a Screen

```dart
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);
    
    return productsAsync.when(
      data: (result) => result.fold(
        onSuccess: (products) => ListView.builder(...),
        onError: (failure) => ErrorWidget(failure.message),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error.toString()),
    );
  }
}
```

### Using Cart Provider

```dart
final cart = ref.watch(cartProvider);
cart.fold(
  onSuccess: (cartEntity) {
    // Use cartEntity.items, cartEntity.totalAmount, etc.
  },
  onError: (failure) {
    // Handle error
  },
);

// Add item to cart
ref.read(cartProvider.notifier).addItem(product);
```

