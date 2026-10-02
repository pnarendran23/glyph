import Foundation
import Photos

/// A lightweight, identifiable wrapper around a `PHAsset`.
/// Required by SwiftUI to safely present modals using `.fullScreenCover(item:)`.
struct SelectedAsset: Identifiable {
    /// Satisfies the `Identifiable` protocol using the exact database string.
    var id: String { asset.localIdentifier }
    
    /// The underlying photo asset passed to the full-screen view.
    let asset: PHAsset
    
    /// Wraps a standard `PHAsset` so it can trigger SwiftUI sheet presentations.
    /// - Parameter asset: The user's tapped photo.
    init(asset: PHAsset) {
        self.asset = asset
    }
}
