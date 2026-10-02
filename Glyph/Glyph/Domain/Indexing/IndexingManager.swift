import Foundation
import SwiftData
import Photos

/// Orchestrates the heavy lifting of extracting text and saving it to the database.
/// Isolated to the `@MainActor` to safely interact with SwiftData's `ModelContext`.
@MainActor
final class IndexingManager {
    
    /// Processes an array of unindexed photos, extracts their text, and saves them to SwiftData.
    /// - Parameters:
    ///   - assets: The raw `PHAsset` items retrieved from the user's camera roll.
    ///   - modelContext: The SwiftData context used to persist the records.
    static func processAll(assets: [PHAsset], modelContext: ModelContext) async {
        var pendingSaves = 0
        
        for asset in assets {
            // Await the Vision framework's OCR extraction
            let tags: [String] = await withCheckedContinuation { continuation in
                PhotoTagger.analyzeAsset(asset) { result in
                    continuation.resume(returning: result)
                }
            }
            
            // Create and insert the database record
            let indexedPhoto = IndexedPhoto(assetIdentifier: asset.localIdentifier, tags: tags)
            modelContext.insert(indexedPhoto)
            
            pendingSaves += 1
            
            // Batch saves every 25 photos to optimize memory and keep the UI at 60fps
            if pendingSaves >= 25 {
                try? modelContext.save()
                pendingSaves = 0
            }
            
            // Native Swift 6 breather (50 milliseconds) to prevent locking up the device
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
        
        // Ensure any remaining records are saved before exiting
        try? modelContext.save()
        print("All photos indexed and saved.")
    }
}
