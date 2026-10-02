# 📱 Glyph

**The 100% Offline, AI-Powered Document Vault for iOS**

Glyph is a privacy-first iOS application built entirely in Swift 6. It silently monitors your photo library in the background, extracts text from screenshots, receipts, and documents using Apple's Vision framework, and indexes them in a local SwiftData vault. No cloud, no tracking, no subscriptions.

---

## ✨ Features

*   **100% Offline OCR:** Uses on-device Neural Engine processing (`VNRecognizeTextRequest`) to extract text instantly. Your data never leaves your iPhone.
*   **Background Indexing:** Silently listens for new screenshots and photos using a custom, Sendable `PHPhotoLibraryChangeObserver`, batching database inserts to preserve battery life.
*   **Instant Search:** Tokenized logical AND filtering ensures lightning-fast queries across thousands of documents.
*   **Premium Dark Mode UI:** Locked to `.dark` color scheme for a sleek, secure feel. 
*   **60FPS Masonry Grid:** Custom in-memory `NSCache` for opportunistic thumbnail loading keeps scrolling perfectly smooth, even with massive libraries.

## 🏗️ Architecture

Glyph is built using a strict **Feature-Driven MVVM (Clean Architecture)** pattern, optimized for Swift 6 strict concurrency. 

```text
Glyph/
├── App/           # Entry point & Onboarding routing
├── Core/          # Shared utilities (ThumbnailCache)
├── Data/          # SwiftData Models (IndexedPhoto)
├── Domain/        # Business Logic & Background Services (Vision, PhotoKit)
└── Presentation/  # Dumb Views & ViewModels (GalleryViewModel)
```

*   **UI Isolation:** Views never talk to iOS frameworks or the database directly. They bind to ViewModels, which request data from the Domain layer.
*   **Swift 6 Compliance:** All Apple framework delegates (like `PHPhotoLibraryChangeObserver`) are isolated using structured concurrency (`Task`, `@MainActor`) and explicit `start()`/`stop()` lifecycles to prevent data races and memory leaks.

## 🛠️ Tech Stack

*   **Language:** Swift 6 (Strict Concurrency enabled)
*   **UI Framework:** SwiftUI
*   **Database:** SwiftData
*   **Frameworks:** PhotoKit, Vision Framework
*   **Upcoming AI:** Core ML (MobileCLIP integration for semantic vector search)

## 🚀 Getting Started

### Prerequisites
*   Xcode 16.0+
*   iOS 18.0+ Target
*   An actual iOS device (Camera roll features and Neural Engine OCR perform best on a physical device, though the simulator will work for basic testing).

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/pnarendran23/glyph.git
   ```
2. Open `Glyph.xcodeproj` in Xcode.
3. Select your team in the **Signing & Capabilities** tab.
4. Ensure your `Info.plist` contains the `NSPhotoLibraryUsageDescription` key.
5. Build and run (`Cmd + R`).

## 🗺 Roadmap

- [x] Onboarding Flow & Privacy Setup
- [x] Background Photo Observer & SwiftData Integration
- [x] Vision-based OCR Indexing
- [x] Masonry Grid UI & In-Memory Image Caching
- [ ] **Core ML Integration:** Replace exact-text matching with MobileCLIP vector embeddings (Cosine Similarity Search).
- [ ] **Smart Snippets:** Highlight exactly where the text was found on the image UI.

---

## ⭐️ Support the Project
If you like this idea or found the Swift 6 Clean Architecture implementations helpful, please consider leaving a **Star** ⭐️ on this repository! It helps others discover the project and motivates me to keep building in public.

## 📬 Connect with Me
I love talking about iOS development, Swift 6, and local AI. Let's connect!
*   **LinkedIn:** [@PradheepNarendran Perambalam](https://www.linkedin.com/in/pradheepnarendran-perambalam-44360a53/)
*   **YouTube:** [@Code With Naren](https://www.youtube.com/@codewithnaren)
