# Health Recorder App

A comprehensive Flutter application for tracking personal health and wellness activities, featuring emotion logging, diet tracking, and workout recording capabilities.

## Features

### 1. Emotion Recording
- Record daily moods using emoji selections
- View mood history with timestamps
- Track emotional patterns over time
- Earn points for consistent mood logging

### 2. Diet Tracking
- Log food items with calorie information
- Auto-complete from previously entered foods
- Edit calorie information for existing entries
- View comprehensive diet history
- Earn points for maintaining diet records

### 3. Workout Monitoring
- Record various types of exercises:
  - Cardio (Running, Cycling, Swimming)
  - Strength Training (Bench Press, Squats, etc.)
  - Flexibility (Yoga)
- Track duration or repetitions
- Automatic calorie burn calculation
- View workout history
- Earn points for exercise activities

### 4. Gamification & Social Features
- Point-based reward system for consistent tracking
- Leaderboard functionality
- User rankings based on activity points
- Social competition elements
- Dedication level progression system

### 5. Multi-language Support
- English and Indonesian language options
- Localized interface elements
- Easy language switching

### 6. Cross-platform Design
- Material Design for Android
- Cupertino style for iOS
- Adaptive UI based on platform

### 7. Data Management
- Local SQLite database using Floor
- Firebase integration for cloud storage
- User authentication
- Data synchronization between devices

### 8. Privacy & Security
- Secure user authentication
- Terms and conditions agreement
- Data deletion capabilities
- Private data protection

## Technical Stack

- **Frontend**: Flutter
- **Database**: 
  - Local: Floor (SQLite)
  - Cloud: Firebase Firestore
- **Authentication**: Firebase Auth
- **Cloud Functions**: Firebase Cloud Functions
- **State Management**: Provider
- **Navigation**: GoRouter
- **Localization**: Custom implementation with JSON

## Architecture

The app follows a provider-based architecture with:
- Entity models for data structure
- DAO patterns for database operations
- Service layers for business logic
- UI components for presentation
- State management for data flow

## Getting Started

1. Clone the repository
2. Install Flutter dependencies
3. Configure Firebase project
4. Run the application

## Testing

The project includes widget tests for core functionalities:
- Emotion recording tests
- Diet tracking tests
- Workout logging tests