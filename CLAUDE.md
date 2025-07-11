# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **DoNext** - a comprehensive native iOS/macOS task management application built with SwiftUI and SwiftData. The app features a complete onboarding flow, authentication system, categorized task management, and modern UI design.

## Development Commands

### Building and Running
```bash
# Build the project
xcodebuild -project DoNext.xcodeproj -scheme DoNext -configuration Debug build

# Run tests
xcodebuild -project DoNext.xcodeproj -scheme DoNext -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run unit tests only
xcodebuild -project DoNext.xcodeproj -scheme DoNext -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:DoNextTests test

# Run UI tests only
xcodebuild -project DoNext.xcodeproj -scheme DoNext -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:DoNextUITests test
```

### Using Xcode
```bash
# Open the project in Xcode
open DoNext.xcodeproj

# Build and run in simulator: Cmd+R
# Run tests: Cmd+U
# Run specific test: Right-click on test method and select "Run"
```

## Architecture Overview

### Core Architecture
- **SwiftUI** - Declarative UI framework with comprehensive view hierarchy
- **SwiftData** - Data persistence and modeling with CloudKit integration ready
- **Coordinator Pattern** - Navigation management with AppCoordinator and HomeCoordinator
- **MVVM Pattern** - Model-View-ViewModel architecture with reactive state management
- **Strategy Pattern** - Authentication system with pluggable sign-in methods
- **Component-based Design** - Modular UI components for better maintainability
- **Multi-platform** - Supports iOS, macOS, and visionOS

### Project Structure
```
DoNext/
├── DoNext/                          # Main app target
│   ├── DoNextApp.swift             # App entry point, SwiftData setup, and navigation
│   ├── Coordinators/               # Navigation coordination
│   │   ├── AppCoordinator.swift    # Main app navigation and state management
│   │   ├── HomeCoordinator.swift   # Home page navigation coordination
│   │   └── Coordinator.swift       # Base coordinator protocol and types
│   ├── Models/                     # Data models and business logic
│   │   ├── TodoItem.swift          # SwiftData model for tasks
│   │   ├── Category.swift          # SwiftData model for categories
│   │   ├── RepeatType.swift        # Reminder repeat patterns
│   │   ├── AuthModels.swift        # Authentication models
│   │   └── OnboardingModels.swift  # Onboarding configuration
│   ├── Services/                   # Business services and managers
│   │   ├── NotificationManager.swift      # Local notification handling
│   │   ├── CloudKitManager.swift          # iCloud sync management
│   │   ├── SettingsManager.swift          # App settings persistence
│   │   └── AuthenticationStrategy.swift   # Authentication strategies
│   ├── Views/                      # UI components and screens
│   │   ├── Authentication/         # Login and auth flows
│   │   │   └── LoginView.swift
│   │   ├── Onboarding/            # App introduction flow
│   │   │   └── LandingPageView.swift
│   │   ├── Home/                  # Main task management interface
│   │   │   ├── HomeView.swift
│   │   │   └── Components/        # Home-specific components
│   │   │       ├── HomeCategoryTabs.swift     # Category navigation tabs
│   │   │       ├── HomeTodoListContainer.swift # Todo list container
│   │   │       ├── CategoryActionBar.swift     # Edit/delete action bar
│   │   │       ├── HomeSearchBar.swift        # Search functionality
│   │   │       ├── HomeEmptyState.swift       # Empty state display
│   │   │       ├── HomeFloatingAddButton.swift # Quick add button
│   │   │       └── HomeToolbarContent.swift   # Toolbar items
│   │   ├── Todo/                  # Task management
│   │   │   ├── TodoCreationSheet.swift # Task creation form
│   │   │   ├── TodoEditSheet.swift     # Task editing form
│   │   │   ├── CategoryCreationSheet.swift # Category creation
│   │   │   ├── CategoryEditSheet.swift     # Category editing
│   │   │   └── Components/        # Todo form components
│   │   │       ├── TodoFormTitleSection.swift    # Title input
│   │   │       ├── TodoFormCategorySection.swift # Category selection
│   │   │       ├── TodoFormReminderSection.swift # Reminder settings
│   │   │       ├── TodoFormRepeatSection.swift   # Repeat options
│   │   │       └── TodoFormToolbarContent.swift  # Form toolbar
│   │   ├── Settings/              # App configuration
│   │   │   ├── SettingsView.swift
│   │   │   └── Components/        # Settings sections
│   │   │       ├── SettingsAccountSection.swift   # Account management
│   │   │       ├── SettingsCloudSyncSection.swift # Sync settings
│   │   │       └── SettingsOtherSection.swift     # General settings
│   │   └── Components/            # Shared UI components
│   │       ├── TodoDetailView.swift    # Task detail display
│   │       ├── HomeComponents.swift    # Shared home components
│   │       ├── AuthenticationComponents.swift # Auth UI elements
│   │       └── OnboardingComponents.swift      # Onboarding UI
│   ├── ViewModels/                # View model layer
│   │   ├── TodoCreationViewModel.swift # Task creation logic
│   │   └── HomeViewModel.swift         # Home screen logic
│   ├── Extensions/                # Swift extensions
│   │   └── Extensions.swift       # Color, Date, and other extensions
│   ├── Assets.xcassets/          # App icons and assets
│   └── DoNext.entitlements       # App permissions and capabilities
├── DoNextTests/                   # Unit tests using Swift Testing
│   └── DoNextTests.swift         # Test cases for models and state management
└── DoNextUITests/                 # UI tests using XCTest
    ├── DoNextUITests.swift
    └── DoNextUITestsLaunchTests.swift
```

### Key Components

#### Data Models (`Models/`)
- **TodoItem**: SwiftData model for individual tasks with reminders, categories, and completion status
- **Category**: SwiftData model for task organization with color coding
- **RepeatType**: Enum for reminder repeat patterns (none, daily, weekly, monthly, yearly)
- **AuthModels**: Authentication-related models and strategies
- **OnboardingModels**: Configuration for app introduction flow

#### Navigation System (`Coordinators/`)
- **AppCoordinator**: Main application navigation and state management
  - Manages onboarding, authentication, and main app states
  - Handles Sheet and Alert presentations
  - Coordinates between different app sections
- **HomeCoordinator**: Home page specific navigation
  - Manages todo detail views, creation/editing sheets
  - Handles category management operations
  - Coordinates with AppCoordinator for global actions
- **Coordinator Protocol**: Base coordinator functionality and navigation types

#### Services Layer (`Services/`)
- **NotificationManager**: Local notification scheduling and management
- **CloudKitManager**: iCloud sync status and operations
- **SettingsManager**: App settings persistence with UserDefaults
- **AuthenticationStrategy**: Pluggable authentication providers

#### UI Architecture (`Views/`)
- **Component-based Design**: Modular, reusable UI components
- **Feature-based Organization**: Views grouped by functionality
- **Shared Components**: Reusable elements across different screens

#### Onboarding (`LandingPageView.swift`)
- Multi-page introduction with configurable content
- Custom page indicators and navigation controls
- Smooth transitions and animations
- Skip functionality and completion tracking

#### Authentication (`LoginView.swift`)
- Apple Sign-In and Google Sign-In buttons (mock implementation)
- Strategy pattern for different authentication providers
- Error handling and loading states
- Privacy policy and terms of service links

#### Main Interface (`Home/`)
- **HomeView**: Main task management interface with edge swipe navigation
- **HomeCategoryTabs**: Category navigation with long-press action bar trigger
- **CategoryActionBar**: Overlay action bar for category edit/delete operations
- **HomeTodoListContainer**: Todo list with swipe-to-delete functionality
- **HomeSearchBar**: Real-time task filtering
- **HomeFloatingAddButton**: Quick task creation
- **HomeEmptyState**: User-friendly empty state messaging

#### Task Management (`Todo/`)
- **TodoCreationSheet**: Task creation form with title, category, reminder settings
- **TodoEditSheet**: Task editing form with pre-populated data
- **TodoFormComponents**: Modular form sections (Title, Category, Reminder, Repeat)
- **CategoryCreationSheet**: Category creation with color selection
- **CategoryEditSheet**: Category editing with existing data pre-fill

#### Task Detail (`Components/TodoDetailView.swift`)
- **Comprehensive Display**: Shows all task properties with proper formatting
- **Edit Integration**: Toolbar button to trigger task editing
- **Visual Elements**: Icons, colors, and status indicators

## Testing Architecture

### Unit Tests (`DoNextTests/`)
- **Swift Testing Framework**: Modern `@Test` attribute-based testing
- **Model Testing**: TodoItem, Category, and RepeatType functionality
- **State Management**: AppState lifecycle and navigation testing
- **Authentication**: Strategy pattern implementation testing
- **Async Support**: Full async/await testing capabilities

### UI Tests (`DoNextUITests/`)
- **XCTest Framework**: Traditional UI automation testing
- **Launch Performance**: App startup time measurements
- **User Flows**: End-to-end user interaction testing

## Feature Specifications

### Task Management
- **CRUD Operations**: Create, read, update, delete tasks
- **Completion Tracking**: Toggle completion status with visual feedback
- **Categorization**: Assign tasks to color-coded categories
- **Reminders**: Set specific date/time reminders with repeat patterns
- **Search**: Real-time search across all tasks
- **Persistence**: SwiftData with local storage and iCloud sync preparation

### Category System
- **CRUD Operations**: Create, read, update, delete categories
- **Color Coding**: 12 preset colors for visual organization
- **Dynamic Navigation**: Swipeable category tabs with task count indicators
- **Long-press Actions**: Action bar with edit/delete options
- **Live Preview**: Real-time category appearance preview
- **Safe Deletion**: Automatically unlinks todos when deleting categories
- **Flexible Organization**: Tasks can be uncategorized or categorized

### User Experience
- **Onboarding Flow**: Multi-page introduction with skip option
- **Authentication**: Apple Sign-In and Google Sign-In support
- **Edge Swipe Navigation**: iOS-style edge gestures for category switching
- **Gesture System**: Zero-conflict gesture handling (swipe-to-delete + edge navigation)
- **Responsive Design**: Adaptive layouts for iPhone, iPad, and Mac
- **Accessibility**: VoiceOver support and semantic markup
- **Animations**: Smooth transitions and micro-interactions

## Development Notes

### SwiftData Integration
- **Model Container**: Configured in DoNextApp.swift with persistent storage
- **Relationships**: Category-TodoItem relationship with proper cascade handling
- **Queries**: Reactive data fetching with @Query property wrapper
- **iCloud Sync**: Architecture ready for CloudKit integration

### State Management
- **Coordinator Pattern**: Centralized navigation management
  - AppCoordinator: Global app state and navigation
  - HomeCoordinator: Feature-specific navigation
- **SwiftUI State**: @State, @Binding, and @Environment for reactive UI
- **Authentication**: Strategy pattern for extensible sign-in methods
- **Persistence**: UserDefaults for app state, SwiftData for task data

### UI Patterns
- **Sheet Presentations**: Modal forms for task and category creation/editing
- **Action Bar Pattern**: Overlay action bars for contextual operations
- **Component Composition**: Modular, reusable UI components
- **Gesture Handling**: Sophisticated gesture recognition and conflict resolution
- **Adaptive Layouts**: Responsive design for different screen sizes
- **Platform Adaptation**: Conditional compilation for iOS/macOS differences

### Gesture System Design
- **Edge Swipe Navigation**: Category switching via screen edge gestures
  - Left edge right-swipe: Previous category
  - Right edge left-swipe: Next category
  - 50-point edge detection zone
- **Swipe-to-Delete**: Native SwiftUI swipeActions for todo deletion
- **Long-press Actions**: Category action bar trigger with visual feedback
- **Conflict Resolution**: Separate gesture zones to prevent interference

### Code Quality
- **Comprehensive Comments**: All models, views, and functions fully documented in Traditional Chinese
- **Error Handling**: Proper error propagation and user feedback
- **Validation**: Input validation throughout the application
- **Performance**: Efficient data loading and UI updates
- **Component Architecture**: Modular design for better maintainability
- **Separation of Concerns**: Clear separation between UI, business logic, and data layers

### Development Guidelines
- **Navigation**: Always use Coordinator pattern for navigation
- **State Management**: Use @Environment for dependency injection
- **UI Components**: Prefer composition over inheritance
- **Gesture Handling**: Test gesture interactions thoroughly to avoid conflicts
- **Form Validation**: Implement real-time validation with user feedback
- **Sheet Presentations**: Use coordinator methods for consistent navigation
- **Action Bars**: Implement as overlays at top-level views to avoid clipping

### Future Enhancements
- **iCloud Sync**: CloudKit integration for cross-device synchronization
- **Push Notifications**: Local notifications for task reminders
- **Widget Support**: Home screen widgets for quick task access
- **Real Authentication**: Integration with actual Apple/Google Sign-In SDKs