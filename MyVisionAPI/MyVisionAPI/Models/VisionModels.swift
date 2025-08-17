import Foundation
import Vision

// MARK: - Text Recognition Models
struct TextConfidence: Identifiable {
    let id = UUID()
    let text: String
    let confidence: Double
    let boundingBox: CGRect
}

struct TextRecognitionResult {
    let texts: [TextConfidence]
    let processingTime: TimeInterval
}

// MARK: - Rectangle Detection Models
struct RectangleResult: Identifiable {
    let id = UUID()
    let boundingBox: CGRect
    let confidence: Double
}

// MARK: - Body Pose Models
struct BodyPosePoint: Identifiable {
    let id = UUID()
    let jointName: String
    let location: CGPoint
    let confidence: Double
}

struct BodyPoseResult {
    let points: [BodyPosePoint]
    let processingTime: TimeInterval
}

// MARK: - Barcode Models
struct BarcodeResult: Identifiable {
    let id = UUID()
    let payload: String
    let symbology: String
    let boundingBox: CGRect
}

// MARK: - Vision Processing States
enum VisionProcessingState {
    case idle
    case processing
    case completed
    case error(String)
}
