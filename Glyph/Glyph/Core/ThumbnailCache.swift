internal import UIKit
import Photos

/// An in-memory cache for generated photo thumbnails.
/// Prevents the `LazyVGrid` from stuttering or re-requesting images from iOS when the user scrolls quickly.
/// This runs as a Singleton to ensure all grid cells share the exact same memory pool.
final class ThumbnailCache {
    /// The shared global instance of the cache.
    static let shared = ThumbnailCache()
    
    /// The underlying `NSCache` storing the images, keyed by the asset's local identifier.
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Optional: Set a limit so the app doesn't consume too much RAM on older iPhones
        cache.countLimit = 500
    }
    
    /// Retrieves a cached image if it exists.
    /// - Parameter identifier: The `localIdentifier` of the `PHAsset`.
    /// - Returns: The cached `UIImage`, or nil if it hasn't been loaded yet.
    func image(for identifier: String) -> UIImage? {
        cache.object(forKey: identifier as NSString)
    }
    
    /// Saves a newly generated thumbnail into RAM.
    /// - Parameters:
    ///   - image: The `UIImage` returned by the Photos framework.
    ///   - identifier: The `localIdentifier` of the `PHAsset`.
    func cache(_ image: UIImage, for identifier: String) {
        cache.setObject(image, forKey: identifier as NSString)
    }
}
