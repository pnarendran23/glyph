import Foundation
import Photos

/// Safely listens for background changes in the iOS Photo Library (e.g., when the user takes a new screenshot).
/// Marked as `Sendable` to comply with Swift 6 strict concurrency checks.
final class LibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver, Sendable {
    /// The closure executed when a photo library change is detected.
    let onChange: @Sendable (PHChange) -> Void
    
    /// Creates a new observer without starting it.
    /// - Parameter onChange: The action to perform when a change occurs.
    init(onChange: @escaping @Sendable (PHChange) -> Void) {
        self.onChange = onChange
        super.init()
    }
    
    /// Registers the observer with the system. Should be called when the app enters the foreground.
    func start() {
        PHPhotoLibrary.shared().register(self)
    }
    
    /// Unregisters the observer. Must be called to prevent memory leaks and Swift 6 concurrency warnings.
    func stop() {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    /// Internal delegate callback triggered by iOS when the camera roll changes.
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        onChange(changeInstance)
    }
}
