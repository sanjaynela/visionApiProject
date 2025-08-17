# Vision API Demo App

A comprehensive iOS demo app showcasing Apple's Vision framework capabilities, inspired by the Medium article "How I Taught My iPhone to 'See' Like a Human: A Deep Dive into Apple's Vision API".

## Features

This app demonstrates four key Vision API capabilities:

### 1. Text Recognition (OCR)
- Extract text from images with confidence scores
- Beautiful SwiftUI Charts visualization of confidence levels
- Support for both printed and handwritten text
- Real-time processing with on-device AI

### 2. Rectangle Detection
- Detect rectangular shapes in images
- Perfect for document scanning and receipt processing
- Visual overlays showing detected rectangles
- Configurable detection parameters

### 3. Human Body Pose Detection
- Track 17 key body joints
- Real-time pose estimation
- Confidence scores for each joint
- Ideal for fitness and AR applications

### 4. Barcode Detection
- Support for QR codes, UPC, EAN, and more
- Extract barcode payload and symbology
- Visual overlays on detected barcodes
- Copy detected text to clipboard

## Key Benefits

- **Privacy**: All processing happens on-device
- **Speed**: No network latency or API rate limits
- **Cost**: Completely free to use
- **Integration**: Seamless SwiftUI and UIKit integration

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Installation

1. Clone the repository
2. Open `MyVisionAPI.xcodeproj` in Xcode
3. Build and run on a physical device (camera features require device)

## Usage

1. **Launch the app** - You'll see a tab-based interface
2. **Select a feature** - Choose from Text Recognition, Rectangle Detection, Body Pose, or Barcode Detection
3. **Capture or select an image** - Use the camera or photo library
4. **View results** - See real-time processing results with visual overlays

## Architecture

The app follows a clean architecture pattern:

```
MyVisionAPI/
├── Models/
│   └── VisionModels.swift          # Data models for Vision results
├── Services/
│   ├── VisionService.swift         # Core Vision API implementation
│   └── CameraService.swift         # Camera and photo library handling
├── Views/
│   ├── ConfidenceChart.swift       # SwiftUI Charts visualization
│   ├── TextRecognitionView.swift   # OCR interface
│   ├── RectangleDetectionView.swift # Rectangle detection interface
│   ├── BodyPoseView.swift          # Pose detection interface
│   └── BarcodeDetectionView.swift  # Barcode detection interface
└── ContentView.swift               # Main tab interface
```

## Code Examples

### Text Recognition
```swift
let request = VNRecognizeTextRequest { request, error in
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    
    for observation in observations {
        if let topCandidate = observation.topCandidates(1).first {
            print("Detected text: \(topCandidate.string)")
        }
    }
}
```

### Rectangle Detection
```swift
let request = VNDetectRectanglesRequest { request, error in
    guard let results = request.results as? [VNRectangleObservation] else { return }
    
    for rect in results {
        print("Detected rectangle: \(rect.boundingBox)")
    }
}
```

### Body Pose Detection
```swift
let request = VNDetectHumanBodyPoseRequest { request, error in
    guard let results = request.results as? [VNHumanBodyPoseObservation] else { return }
    
    for observation in results {
        if let leftWrist = try? observation.recognizedPoint(.leftWrist) {
            print("Left wrist at: \(leftWrist.location)")
        }
    }
}
```

### Barcode Detection
```swift
let request = VNDetectBarcodesRequest { request, error in
    guard let results = request.results as? [VNBarcodeObservation] else { return }
    
    for barcode in results {
        print("Barcode detected: \(barcode.payloadStringValue ?? "")")
    }
}
```

## Permissions

The app requires the following permissions:
- **Camera**: For capturing images
- **Photo Library**: For selecting existing images

These are automatically requested when needed.

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License.

## Related Articles

- [How to Build a Beautiful Data Dashboard App on iOS Using SwiftUI Charts](https://medium.com/@yourusername/swiftui-charts-dashboard)
- [Mastering Bluetooth on iOS: A Deep Dive into CoreBluetooth](https://medium.com/@yourusername/corebluetooth-deep-dive)

---

Built with ❤️ using Apple's Vision framework and SwiftUI
