# 30 Day Bible Challenge

An iOS app featuring daily Scripture passages via home/lock screen widgets, with premium games and exercises.

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode and create a new project
2. Select **App** template for iOS
3. Product Name: `30DayBibleChallenge`
4. Organization Identifier: `com.biblechallenge`
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Minimum Deployment: **iOS 17.0**

### 2. Add Widget Extension

1. File > New > Target
2. Select **Widget Extension**
3. Product Name: `BibleWidget`
4. Check "Include Configuration App Intent" (optional)
5. Finish

### 3. Copy Source Files

Copy the contents from the `30DayBibleChallenge/` folder into your Xcode project:

- `App/` - Main app entry point
- `Models/` - Data models
- `Views/` - SwiftUI views
- `ViewModels/` - View models
- `Services/` - Data and store services
- `Widget/` - Widget extension files
- `Resources/` - Assets and config files

### 4. Configure App Groups

1. Select project in navigator
2. Select main app target > Signing & Capabilities
3. Add "App Groups" capability
4. Add group: `group.com.biblechallenge.shared`
5. Repeat for Widget extension target

### 5. Add Bible Data

The app includes sample data. For full Bible text, download WEB Bible JSON from:
- https://github.com/thiagobodruk/bible

Place the JSON file as `web_bible.json` in the Data folder and add to the main app target.

### 6. Configure StoreKit

1. Add `Products.storekit` to your project
2. Edit Scheme > Run > Options > StoreKit Configuration: Select `Products.storekit`

### 7. Build & Run

1. Select an iOS 17+ simulator
2. Build and run (Cmd+R)

## Project Structure

```
30DayBibleChallenge/
├── App/                    # App entry & navigation
├── Models/                 # Data models
├── Views/
│   ├── Home/              # Dashboard
│   ├── Reading/           # Daily reading views
│   ├── Games/             # Quiz, Memory, Fill-in-blank
│   ├── Premium/           # Paywall
│   └── Components/        # Reusable components
├── ViewModels/            # MVVM view models
├── Services/              # Data & store services
├── Widget/                # Widget extension
└── Resources/             # Assets & config
```

## Features

### Free Tier
- Daily Bible verse widget (home & lock screen)
- 30-day reading plan
- Progress tracking

### Premium Tier
- Quiz & Trivia games
- Memory verse flashcards
- Fill-in-the-blank exercises
- Full progress analytics

## Tech Stack

- Swift 5.9+
- SwiftUI
- iOS 17.0+
- SwiftData
- WidgetKit
- StoreKit 2
