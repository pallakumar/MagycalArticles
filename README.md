# MagycalArticles

An iOS application for browsing and reading articles, built using UIKit, SwiftUI and MVC architecture.

## Features

- Article listing using UICollectionView.
- Grid and list layout switching.
- Article search functionality.
- Article detail screen.
- Pull-to-refresh support.
- Network connectivity monitoring.
- Offline state with retry functionality.
- Dependency injection using Swinject.
- Logging using XCGLogger.
- Reusable UI components.
- Unit testing support.

## Technology Stack

| Technology | Usage |
|---|---|
| Swift 5 | Programming language |
| UIKit | Main application UI |
| SwiftUI | Custom article header |
| MVC | Application architecture |
| UICollectionView | Article listing |
| Swinject | Dependency injection |
| XCGLogger | Logging |
| Network framework | Connectivity monitoring |
| XCTest | Unit testing |
| CocoaPods | Dependency management |

## Requirements

- macOS compatible with your Xcode installation
- Xcode 13.2.1
- Swift 5.5.2
- iOS Simulator

## Application Screenshots
<img width="600" height="1299" alt="offline-screen" src="https://github.com/user-attachments/assets/af326d90-1243-464e-8271-7b1dc561d41e" />
<img width="600" height="1299" alt="article-search" src="https://github.com/user-attachments/assets/eb944318-997a-493e-ad39-552b03008f30" />
<img width="600" height="1299" alt="article-list" src="https://github.com/user-attachments/assets/9707400d-ac21-437a-b493-f304419bfeda" />
<img width="600" height="1299" alt="article-grid" src="https://github.com/user-attachments/assets/8ec37915-7576-43e1-966c-5572b1381068" />
<img width="600" height="1299" alt="article-details" src="https://github.com/user-attachments/assets/5b907ed6-ac75-4ee5-9be9-d70f20f48e3b" />
<img width="600" height="1299" alt="article-list-refresh" src="https://github.com/user-attachments/assets/f1f7c1bf-a094-4677-a170-14f814717068" />


## Installation

Clone the repository:

```bash
git clone https://github.com/pallakumar/MagycalArticles.git
cd MagycalArticles
```

Install CocoaPods dependencies:

```bash
pod install
```

Open the workspace:

```bash
open MagycalArticles.xcworkspace
```

Select an iOS Simulator and build the application.

## Project Structure

```text
MagycalArticles/
├── Application/
├── Models/
├── Views/
├── Controllers/
├── Services/
├── Storage/
├── Resources/
└── MagycalArticlesTests/
```

Adjust this structure to match the actual folders in the repository.

## Architecture

The application follows MVC:

- Model: Article data and data-related logic.
- View: Article cells and SwiftUI header.
- Controller: Article listing and detail screen coordination.
- Services: API and networking responsibilities.
- Storage: Local persistence, if configured.

## Unit Testing

The test target should cover:

- Article model initialization.
- Article search filtering.
- Article data mapping.
- API success and failure responses.
- Offline connectivity state.
- Article layout configuration.
- Article detail screen data presentation.

Run tests using:

```bash
xcodebuild test \
-scheme MagycalArticles \
-destination 'platform=iOS Simulator,name=iPhone 12 Pro'
```

## Screenshots

Add application screenshots to the `Screenshots` folder and link them here.

## Author

Palla Kumar

GitHub: https://github.com/pallakumar

## License

Add a license if you intend to distribute this project for reuse.
