import Foundation
import Photos
import SwiftData

@MainActor @Observable
final class PhotoLibraryManager {
    /// The current status of the user's camera roll permissions (e.g., `.authorized`, `.denied`).
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    /// The raw, unfiltered photo assets currently fetched from the iOS database.
    var assets: [PHAsset] = []
    
    /// The background listener that alerts the app when a new photo is taken.
    private var changeObserver: LibraryChangeObserver?
    
    /// Requests privacy permissions from the user and triggers the initial fetch if granted.
    func checkAuthorization(modelContext: ModelContext) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
          let selfUW = self
          let container = modelContext.container
          PHPhotoLibrary.requestAuthorization(for: .readWrite) { [selfUW, container] newStatus in
                Task { @MainActor in
                  selfUW.authorizationStatus = newStatus
                    if newStatus == .authorized || newStatus == .limited {
                      selfUW.setupAndFetch(modelContext: container.mainContext)
                    }
                }
            }
        } else {
            authorizationStatus = status
            if status == .authorized || status == .limited {
                setupAndFetch(modelContext: modelContext)
            }
        }
    }
    
    /// Configures the background observer and pulls down the initial list of images.
    private func setupAndFetch(modelContext: ModelContext) {
        // Fix 1: Stop any existing observer before creating a new one to prevent memory leaks
        changeObserver?.stop()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var fetchedAssets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            fetchedAssets.append(asset)
        }
        self.assets = fetchedAssets
        
        Task {
            await IndexingManager.processAll(assets: fetchedAssets, modelContext: modelContext)
        }
        
        // Fix 2: Extract the Sendable container to bypass the Swift 6 ModelContext capture warning
        let container = modelContext.container
        let selfUW = self
        changeObserver = LibraryChangeObserver { [selfUW, container] _ in
            Task { @MainActor in
                // Safely recreate the main context on the Main Actor
                let context = container.mainContext
                selfUW.setupAndFetch(modelContext: context)
            }
        }
        changeObserver?.start()
    }
    
    // Fix 3: Removed `deinit` and replaced it with an explicit cleanup method
    func stopObserving() {
        changeObserver?.stop()
        changeObserver = nil
    }
}
