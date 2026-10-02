import Foundation
import Photos
import Vision
internal import UIKit

/// The OCR engine powered by Apple's Vision framework.
/// Extracts raw text strings from physical documents, receipts, and screenshots without needing a network connection.
struct PhotoTagger {
    
    /// Requests the high-res image from iOS and feeds it into the Neural Engine for text recognition.
    /// - Parameters:
    ///   - asset: The photo to analyze.
    ///   - completion: A callback containing an array of lowercase text strings found in the image.
    static func analyzeAsset(_ asset: PHAsset, completion: @escaping ([String]) -> Void) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true // Allows iCloud downloads if the image is offloaded
        options.deliveryMode = .highQualityFormat
        
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { image, _ in
            guard let cgImage = image?.cgImage else {
                completion([])
                return
            }
            
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                    completion([])
                    return
                }
                
                // Extract the top candidate for each block of text and lowercase it for easy searching
                let foundTags = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string.lowercased()
                }
                completion(foundTags)
            }
            
            // Prioritize accuracy over speed since this runs entirely in the background
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Vision OCR failed for asset \(asset.localIdentifier): \(error)")
                completion([])
            }
        }
    }
}
