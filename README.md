# Vision API Demo App

A comprehensive iOS demo app showcasing Apple's Vision framework capabilities, inspired by the Medium article "How I Taught My iPhone to 'See' Like a Human: A Deep Dive into Apple's Vision API".

## 🎯 Overview

This app demonstrates the power of Apple's on-device AI by implementing four key Vision API features with a beautiful SwiftUI interface. All processing happens locally on your device, ensuring privacy and speed.

## ✨ Features

### 📝 Text Recognition (OCR)
- **Extract text** from images with confidence scores
- **Beautiful SwiftUI Charts** visualization of confidence levels
- **Support for both printed and handwritten text**
- **Real-time processing** with on-device AI
- **Processing time tracking** for performance monitoring

### 📐 Rectangle Detection
- **Detect rectangular shapes** in images
- **Perfect for document scanning** and receipt processing
- **Visual overlays** showing detected rectangles
- **Configurable detection parameters** (aspect ratio, size limits)
- **Bounding box coordinates** and confidence scores

### 🏃‍♂️ Human Body Pose Detection
- **Track 17 key body joints** (nose, eyes, shoulders, elbows, wrists, hips, knees, ankles)
- **Real-time pose estimation** with confidence scores
- **Visual joint overlays** on detected poses
- **Ideal for fitness and AR applications**
- **Processing time optimization**

### 📱 Barcode Detection
- **Support for multiple formats**: QR codes, UPC, EAN, Code 128, and more
- **Extract barcode payload** and symbology information
- **Visual overlays** on detected barcodes
- **Copy detected text** to clipboard
- **Multiple barcode detection** in single image

## 🚀 Key Benefits

- **🔒 Privacy**: All processing happens on-device, no data sent to cloud
- **⚡ Speed**: No network latency or API rate limits
- **💰 Cost**: Completely free to use, no subscription required
- **🔧 Integration**: Seamless SwiftUI and UIKit integration
- **📊 Visualization**: Beautiful charts and real-time feedback
- **🎨 Modern UI**: Clean, intuitive interface with proper error handling

## 📋 Requirements

- **iOS 15.0+** (for latest Vision framework features)
- **Xcode 14.0+** (for SwiftUI Charts support)
- **Swift 5.7+**
- **Physical Device** (camera features require real device)

## 🛠️ Installation

### Prerequisites
1. **Xcode** installed on your Mac
2. **iOS device** for testing (camera features don't work in simulator)
3. **Apple Developer account** (free account works for testing)

### Setup Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/sanjaynela/visionApiProject.git
   cd visionApiProject
   ```

2. **Open in Xcode**
   ```bash
   open MyVisionAPI/MyVisionAPI.xcodeproj
   ```

3. **Configure signing**
   - Select the `MyVisionAPI` target
   - Go to "Signing & Capabilities"
   - Select your team (personal team works for testing)

4. **Build and run**
   - Select your device from the device picker
   - Press `Cmd+R` to build and run

## 📱 Usage

### Getting Started
1. **Launch the app** - You'll see a welcome screen explaining the features
2. **Tap "Get Started"** - Access the main tab-based interface
3. **Select a feature** - Choose from the four Vision API capabilities
4. **Capture or select an image** - Use camera or photo library
5. **Tap "Process with Vision API"** - See real-time results

### Testing Each Feature

#### Text Recognition
- **Best for**: Documents, signs, handwritten notes, receipts
- **Tips**: Ensure good lighting and clear text
- **Results**: Extracted text with confidence scores and charts

#### Rectangle Detection
- **Best for**: Documents, business cards, receipts, screenshots
- **Tips**: Hold device parallel to rectangular objects
- **Results**: Detected rectangles with bounding boxes

#### Body Pose Detection
- **Best for**: People in various poses, fitness tracking
- **Tips**: Ensure person is fully visible in frame
- **Results**: 17 body joints with confidence scores

#### Barcode Detection
- **Best for**: QR codes, product barcodes, tickets
- **Tips**: Ensure barcode is well-lit and in focus
- **Results**: Extracted data and symbology information

## 🏗️ Architecture

The app follows a clean MVVM architecture pattern:

```
MyVisionAPI/
├── Models/
│   └── VisionModels.swift          # Data models for Vision results
├── Services/
│   ├── VisionService.swift         # Core Vision API implementation
│   └── CameraService.swift         # Camera and photo library handling
├── Views/
│   ├── WelcomeView.swift           # Onboarding screen
│   ├── ConfidenceChart.swift       # SwiftUI Charts visualization
│   ├── TextRecognitionView.swift   # OCR interface
│   ├── RectangleDetectionView.swift # Rectangle detection interface
│   ├── BodyPoseView.swift          # Pose detection interface
│   └── BarcodeDetectionView.swift  # Barcode detection interface
├── ContentView.swift               # Main tab interface
├── MyVisionAPIApp.swift           # App entry point
├── Info.plist                     # Privacy permissions
└── MyVisionAPI.entitlements       # App sandbox permissions
```

## 💻 Code Examples

### Text Recognition with Confidence
```swift
let request = VNRecognizeTextRequest { request, error in
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    
    for observation in observations {
        if let topCandidate = observation.topCandidates(1).first {
            let confidence = topCandidate.confidence
            let text = topCandidate.string
            print("Text: \(text), Confidence: \(confidence)")
        }
    }
}

// Configure for better accuracy
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true
```

### Rectangle Detection with Configuration
```swift
let request = VNDetectRectanglesRequest { request, error in
    guard let results = request.results as? [VNRectangleObservation] else { return }
    
    for rect in results {
        let boundingBox = rect.boundingBox
        let confidence = rect.confidence
        print("Rectangle: \(boundingBox), Confidence: \(confidence)")
    }
}

// Configure detection parameters
request.minimumAspectRatio = 0.3
request.maximumAspectRatio = 3.0
request.minimumSize = 0.1
request.maximumObservations = 10
```

### Body Pose Detection with Joint Tracking
```swift
let request = VNDetectHumanBodyPoseRequest { request, error in
    guard let results = request.results as? [VNHumanBodyPoseObservation] else { return }
    
    for observation in results {
        let joints: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .leftShoulder, .rightShoulder, .leftWrist, .rightWrist
        ]
        
        for joint in joints {
            if let point = try? observation.recognizedPoint(joint) {
                let location = point.location
                let confidence = point.confidence
                print("\(joint): \(location), Confidence: \(confidence)")
            }
        }
    }
}
```

### Barcode Detection with Multiple Formats
```swift
let request = VNDetectBarcodesRequest { request, error in
    guard let results = request.results as? [VNBarcodeObservation] else { return }
    
    for barcode in results {
        let payload = barcode.payloadStringValue ?? ""
        let symbology = barcode.symbology
        let boundingBox = barcode.boundingBox
        print("Barcode: \(payload), Type: \(symbology), Box: \(boundingBox)")
    }
}
```

## 🔐 Permissions

The app requires the following permissions (automatically requested):

- **Camera** (`NSCameraUsageDescription`): For capturing images
- **Photo Library** (`NSPhotoLibraryUsageDescription`): For selecting existing images

These permissions are configured in `Info.plist` and requested when needed.

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
- **"Multiple commands produce Info.plist"**: Clean build folder (`Cmd+Shift+K`) and rebuild
- **"Cannot find module"**: Ensure all files are added to the target
- **Signing issues**: Check your team selection in project settings

#### Runtime Issues
- **Camera not working**: Ensure you're running on a physical device
- **Permissions denied**: Go to Settings → Privacy & Security → Camera/Photos
- **App crashes on photo library**: Add privacy permissions to Info.plist

#### Performance Issues
- **Slow processing**: First run loads models, subsequent runs are faster
- **Memory issues**: Process smaller images or reduce image quality
- **Battery drain**: Vision API is optimized for efficiency

### Debug Tips
- Check Xcode console for detailed error messages
- Use device logs for permission-related issues
- Test with different image types and sizes

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Ideas for Contributions
- Add more Vision API features (face detection, object tracking)
- Improve UI/UX with animations and transitions
- Add unit tests and UI tests
- Support for video processing
- Export results to various formats

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 📚 Related Articles

- [How I Taught My iPhone to "See" Like a Human: A Deep Dive into Apple's Vision API](https://medium.com/@sanjaynela/vision-api-deep-dive) - The inspiration for this project
- [How to Build a Beautiful Data Dashboard App on iOS Using SwiftUI Charts](https://medium.com/@sanjaynela/swiftui-charts-dashboard)
- [Mastering Bluetooth on iOS: A Deep Dive into CoreBluetooth](https://medium.com/@sanjaynela/corebluetooth-deep-dive)

## 🙏 Acknowledgments

- **Apple** for the amazing Vision framework
- **SwiftUI Charts** for beautiful data visualization
- **The iOS development community** for inspiration and support

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/sanjaynela/visionApiProject/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sanjaynela/visionApiProject/discussions)
- **Email**: [sanjay@example.com](mailto:sanjay@example.com)

---

**Built with ❤️ using Apple's Vision framework and SwiftUI**

*This project demonstrates the power of on-device AI and showcases best practices for implementing Apple's Vision framework in modern iOS applications.*
