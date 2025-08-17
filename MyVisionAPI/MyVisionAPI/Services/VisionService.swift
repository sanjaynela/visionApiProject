import Foundation
import Vision
import UIKit
import CoreImage

class VisionService: ObservableObject {
    @Published var processingState: VisionProcessingState = .idle
    @Published var textResults: TextRecognitionResult?
    @Published var rectangleResults: [RectangleResult] = []
    @Published var bodyPoseResults: BodyPoseResult?
    @Published var barcodeResults: [BarcodeResult] = []
    
    // MARK: - Text Recognition
    func recognizeText(from image: UIImage, completion: @escaping (TextRecognitionResult?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let startTime = Date()
        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.processingState = .error(error.localizedDescription)
                    completion(nil)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion(nil)
                    return
                }
                
                let texts = observations.compactMap { observation -> TextConfidence? in
                    guard let topCandidate = observation.topCandidates(1).first else { return nil }
                    return TextConfidence(
                        text: topCandidate.string,
                        confidence: Double(topCandidate.confidence),
                        boundingBox: observation.boundingBox
                    )
                }
                
                let result = TextRecognitionResult(
                    texts: texts,
                    processingTime: Date().timeIntervalSince(startTime)
                )
                
                self?.textResults = result
                self?.processingState = .completed
                completion(result)
            }
        }
        
        // Configure for better accuracy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.processingState = .error(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Rectangle Detection
    func detectRectangles(from image: UIImage, completion: @escaping ([RectangleResult]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let request = VNDetectRectanglesRequest { [weak self] request, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.processingState = .error(error.localizedDescription)
                    completion([])
                    return
                }
                
                guard let results = request.results as? [VNRectangleObservation] else {
                    completion([])
                    return
                }
                
                let rectangles = results.map { observation in
                    RectangleResult(
                        boundingBox: observation.boundingBox,
                        confidence: Double(observation.confidence)
                    )
                }
                
                self?.rectangleResults = rectangles
                self?.processingState = .completed
                completion(rectangles)
            }
        }
        
        // Configure rectangle detection
        request.minimumAspectRatio = 0.3
        request.maximumAspectRatio = 3.0
        request.minimumSize = 0.1
        request.maximumObservations = 10
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.processingState = .error(error.localizedDescription)
                    completion([])
                }
            }
        }
    }
    
    // MARK: - Body Pose Detection
    func detectBodyPose(from image: UIImage, completion: @escaping (BodyPoseResult?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let startTime = Date()
        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.processingState = .error(error.localizedDescription)
                    completion(nil)
                    return
                }
                
                guard let results = request.results as? [VNHumanBodyPoseObservation] else {
                    completion(nil)
                    return
                }
                
                guard let observation = results.first else {
                    completion(nil)
                    return
                }
                
                var points: [BodyPosePoint] = []
                
                // Define key joints to track
                let joints: [VNHumanBodyPoseObservation.JointName] = [
                    .nose, .leftEye, .rightEye, .leftEar, .rightEar,
                    .leftShoulder, .rightShoulder, .leftElbow, .rightElbow,
                    .leftWrist, .rightWrist, .leftHip, .rightHip,
                    .leftKnee, .rightKnee, .leftAnkle, .rightAnkle
                ]
                
                for joint in joints {
                    if let point = try? observation.recognizedPoint(joint) {
                        let bodyPoint = BodyPosePoint(
                            jointName: String(describing: joint),
                            location: point.location,
                            confidence: Double(point.confidence)
                        )
                        points.append(bodyPoint)
                    }
                }
                
                let result = BodyPoseResult(
                    points: points,
                    processingTime: Date().timeIntervalSince(startTime)
                )
                
                self?.bodyPoseResults = result
                self?.processingState = .completed
                completion(result)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.processingState = .error(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Barcode Detection
    func detectBarcodes(from image: UIImage, completion: @escaping ([BarcodeResult]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.processingState = .error(error.localizedDescription)
                    completion([])
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation] else {
                    completion([])
                    return
                }
                
                let barcodes = results.compactMap { observation -> BarcodeResult? in
                    guard let payload = observation.payloadStringValue else { return nil }
                    return BarcodeResult(
                        payload: payload,
                        symbology: observation.symbology.rawValue,
                        boundingBox: observation.boundingBox
                    )
                }
                
                self?.barcodeResults = barcodes
                self?.processingState = .completed
                completion(barcodes)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.processingState = .error(error.localizedDescription)
                    completion([])
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    func resetResults() {
        textResults = nil
        rectangleResults = []
        bodyPoseResults = nil
        barcodeResults = []
        processingState = .idle
    }
}
