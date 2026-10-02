//
//  FullScreenPhotoView.swift
//  Glyph
//
//  Created by PradheepNarendran on 02/10/26.
//
import SwiftUI
import Photos

struct FullScreenPhotoView: View {
    let asset: PHAsset
    @Environment(\.dismiss) private var dismiss
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Classic dark gallery background
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        // Optional: Add pinch-to-zoom using standard iOS 17+ modifier if targeting newer iOS
                        // .defaultScrollAnchor(.center)
                } else if isLoading {
                    ProgressView()
                    .tint(Color.primary)
                        .scaleEffect(1.5)
                }
            }
            // Style the navigation bar for a dark theme
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.primary.opacity(0.8))
                    }
                }
            }
        }
        .onAppear {
            loadHighResImage()
        }
    }
    
    private func loadHighResImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        // Ensure we get the highest quality, downloading from iCloud if needed
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        // PHImageManagerMaximumSize requests the original, unscaled image
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { result, info in
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) == true
            
            DispatchQueue.main.async {
                if let result = result {
                    self.image = result
                }
                
                // Stop the loading spinner only when the final, sharp image arrives
                if !isDegraded {
                    self.isLoading = false
                }
            }
        }
    }
}
