//
//  SmartGalleryApp.swift
//  SmartGallery
//
//  Created by PradheepNarendran on 01/10/26.
//

import SwiftUI
import SwiftData

@main
struct SmartGalleryApp: App {
  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some Scene {
      WindowGroup {
        if hasSeenOnboarding {
          PhotoGridView()
        } else {
          OnboardingView()
        }
      }
      .modelContainer(for: IndexedPhoto.self)
    }
}
