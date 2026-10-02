//
//  PhotoGridView.swift
//  Glyph
//
//  Created by PradheepNarendran on 02/10/26.
//
import SwiftUI
import SwiftData
import Photos

struct PhotoGridView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var manager = PhotoLibraryManager()
    @Environment(\.scenePhase) private var scenePhase
    
    // 1. Fetch all indexed photos from SwiftData automatically
    @Query private var indexedPhotos: [IndexedPhoto]
    
    // 2. Track search input
    @State private var searchText = ""
  
    @State private var selectedAsset: SelectedAsset?
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    // 3. Computed property to filter assets based on search text
      var displayedAssets: [PHAsset] {
          let cleanSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
          
          if cleanSearch.isEmpty {
              return manager.assets
          }
          
          // 1. Tokenize: Break the sentence into words and remove punctuation
          let rawTokens = cleanSearch.components(separatedBy: CharacterSet.alphanumerics.inverted)
              .filter { !$0.isEmpty }
              
          // 2. Remove filler "stop words" so they don't break the search
          let stopWords: Set<String> = ["a", "an", "the", "my", "at", "in", "on", "with", "is", "playing", "to", "and", "of"]
          var searchTokens = rawTokens.filter { !stopWords.contains($0) }
          
          // Fallback: If the user *only* typed stop words (e.g., "my"), use the raw tokens
          if searchTokens.isEmpty {
              searchTokens = rawTokens
          }
              
          // 3. Logical AND Filtering
          let matchingIdentifiers = Set(indexedPhotos.compactMap { photo -> String? in
              
              // `allSatisfy` ensures the photo contains EVERY token we are looking for
              let containsAllTokens = searchTokens.allSatisfy { token in
                  photo.tags.contains { tag in
                      tag.localizedStandardContains(token)
                  }
              }
              
              return containsAllTokens ? photo.assetIdentifier : nil
          })
              
          // 4. Return the filtered gallery
          return manager.assets.filter { matchingIdentifiers.contains($0.localIdentifier) }
      }

    var body: some View {
        NavigationStack {
            Group {
                switch manager.authorizationStatus {
                case .authorized, .limited:
                    ScrollView {
                        // Optional: Show count or status of search results
                        if !searchText.isEmpty {
                            Text("Found \(displayedAssets.count) results for \"\(searchText)\"")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }

                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(displayedAssets, id: \.localIdentifier) { asset in
                                AssetThumbnailView(asset: asset)
                                .onTapGesture {
                                  selectedAsset = SelectedAsset(asset: asset)
                                  PhotoTagger.analyzeAsset(asset) { values in
                                    print("Tagged values are \(values)")
                                  }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 5)
                case .denied, .restricted:
                    ContentUnavailableView(
                        "Photo Access Denied",
                        systemImage: "photo.slash",
                        description: Text("Please enable photo permissions in your iOS Settings to view and search your library.")
                    )
                default:
                    ProgressView("Requesting Photo Access...")
                }
            }
            .navigationTitle("Glyph")
            // 4. Attach SwiftUI's native search bar
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Find words in your bills...")
            .onAppear {
                manager.checkAuthorization(modelContext: modelContext)
            }
            .onChange(of: scenePhase) { _, newPhase in
              if newPhase == .active {
                manager.checkAuthorization(modelContext: modelContext)
              }
            }
            .fullScreenCover(item: $selectedAsset) { selection in
              FullScreenPhotoView(asset: selection.asset)
            }
        }
    }
}

