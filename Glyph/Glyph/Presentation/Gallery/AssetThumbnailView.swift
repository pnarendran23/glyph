//
//  AssetThumbnailView.swift
//  Glyph
//
//  Created by PradheepNarendran on 02/10/26.
//
import Photos
import SwiftUI

struct AssetThumbnailView: View {
  let asset: PHAsset
  private static let cachingManager = PHCachingImageManager()
  
  @State private var image: UIImage?
  @State private var requestID: PHImageRequestID?
  
  var body: some View {
    Color.clear
      .aspectRatio(1, contentMode: .fill)
      .overlay(
        Group {
          if let image = image {
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
          } else {
            Rectangle()
              .fill(Color.secondary.opacity(0.2))
          }
        }
      )
      .clipped()
      .onAppear {
        loadThumbnail()
      }
      .onDisappear {
        cancelThumbnailLoad()
      }
  }
  
  private func loadThumbnail() {
    let cacheKey = asset.localIdentifier
    
    // 1. Check memory cache first using the correct method name
    if let cachedImage = ThumbnailCache.shared.image(for: cacheKey) {
      self.image = cachedImage
      return
    }
    
    if image != nil { return }
    
    let targetSize = CGSize(width: 200, height: 200)
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .opportunistic
    options.isSynchronous = false
    options.resizeMode = .exact
    
    requestID = Self.cachingManager.requestImage(
      for: asset,
      targetSize: targetSize,
      contentMode: .aspectFill,
      options: options
    ) { result, info in
      let isCancelled = (info?[PHImageCancelledKey] as? Bool) == true
      
      if let result = result, !isCancelled {
        // 2. Save to cache using the correct method name
        ThumbnailCache.shared.cache(result, for: cacheKey)
        
        // 3. Swift 6 compliant way to update SwiftUI @State
        Task { @MainActor in
          self.image = result
        }
      }
    }
  }
  
  private func cancelThumbnailLoad() {
    if let requestID = requestID {
      Self.cachingManager.cancelImageRequest(requestID)
      self.requestID = nil
    }
    self.image = nil
  }
}
