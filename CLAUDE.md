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
- **MVVM Pattern** - Model-View-ViewModel architecture with reactive state management
- **Strategy Pattern** - Authentication system with pluggable sign-in methods
- **Multi-platform** - Supports iOS, macOS, and visionOS

### Project Structure
```
DoNext/
├── DoNext/                          # Main app target
│   ├── DoNextApp.swift             # App entry point, SwiftData setup, and navigation
│   ├── Item.swift                  # SwiftData models and authentication strategies
│   ├── LandingPageView.swift       # Onboarding/landing page with page indicators
│   ├── LoginView.swift             # Authentication view (Apple/Google Sign-In)
│   ├── HomeView.swift              # Main task management interface
│   ├── TodoCreationSheet.swift     # Task creation form with reminders
│   ├── CategoryCreationSheet.swift # Category creation with color selection
│   ├── Assets.xcassets/           # App icons and assets
│   └── DoNext.entitlements        # App permissions and capabilities
├── DoNextTests/                    # Unit tests using Swift Testing
│   └── DoNextTests.swift          # Test cases for models and state management
└── DoNextUITests/                  # UI tests using XCTest
    ├── DoNextUITests.swift
    └── DoNextUITestsLaunchTests.swift
```

### Key Components

#### Data Models (`Item.swift`)
- **TodoItem**: SwiftData model for individual tasks with reminders, categories, and completion status
- **Category**: SwiftData model for task organization with color coding
- **RepeatType**: Enum for reminder repeat patterns (none, daily, weekly, monthly, yearly)
- **AuthenticationStrategy**: Protocol for pluggable authentication methods
- **AppState**: Observable object managing global application state

#### Navigation Flow (`DoNextApp.swift`)
- **AppState**: Manages onboarding, authentication, and main app states
- **RootView**: State-driven navigation between onboarding, login, and main views
- SwiftData ModelContainer with TodoItem and Category schemas
- UserDefaults integration for onboarding completion tracking

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

#### Main Interface (`HomeView.swift`)
- **Category System**: Swipeable category tabs with color coding
- **Task Management**: Add, edit, delete, and complete tasks
- **Search Functionality**: Real-time task filtering
- **Floating Action Button**: Quick task creation
- **Empty States**: User-friendly empty state messaging

#### Task Creation (`TodoCreationSheet.swift`)
- **Form-based UI**: Title, category selection, reminder settings
- **Date/Time Picker**: Custom date picker for reminders
- **Repeat Options**: Integration with RepeatType enum
- **Validation**: Input validation before task creation

#### Category Management (`CategoryCreationSheet.swift`)
- **Color Selection**: Grid-based color picker with 12 preset colors
- **Live Preview**: Real-time preview of category appearance
- **Validation**: Name requirement and duplicate prevention

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
- **Color Coding**: 12 preset colors for visual organization
- **Dynamic Navigation**: Swipeable tabs with task count indicators
- **Live Preview**: Real-time category appearance preview
- **Flexible Organization**: Tasks can be uncategorized or categorized

### User Experience
- **Onboarding Flow**: Multi-page introduction with skip option
- **Authentication**: Apple Sign-In and Google Sign-In support
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
- **AppState**: Centralized state management with ObservableObject
- **Navigation**: State-driven navigation between app sections
- **Authentication**: Strategy pattern for extensible sign-in methods
- **Persistence**: UserDefaults for app state, SwiftData for task data

### UI Patterns
- **Sheet Presentations**: Modal forms for task and category creation
- **Adaptive Layouts**: Responsive design for different screen sizes
- **Custom Components**: Reusable UI elements with proper styling
- **Platform Adaptation**: Conditional compilation for iOS/macOS differences

### Code Quality
- **Comprehensive Comments**: All models, views, and functions fully documented in Traditional Chinese
- **Error Handling**: Proper error propagation and user feedback
- **Validation**: Input validation throughout the application
- **Performance**: Efficient data loading and UI updates

### Future Enhancements
- **iCloud Sync**: CloudKit integration for cross-device synchronization
- **Push Notifications**: Local notifications for task reminders
- **Widget Support**: Home screen widgets for quick task access
- **Real Authentication**: Integration with actual Apple/Google Sign-In SDKs