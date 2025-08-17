import SwiftUI

struct RectangleDetectionView: View {
    @ObservedObject var visionService: VisionService
    @ObservedObject var cameraService: CameraService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Section with Overlay
                    if let image = cameraService.capturedImage {
                        RectangleImageSection(image: image, rectangles: visionService.rectangleResults)
                    } else {
                        PlaceholderSection()
                    }
                    
                    // Action Buttons
                    ActionButtonsSection()
                    
                    // Results Section
                    if case .processing = visionService.processingState {
                        ProgressView("Detecting rectangles...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if !visionService.rectangleResults.isEmpty {
                        RectangleResultsSection()
                    } else if case .error(let message) = visionService.processingState {
                        ErrorSection(message: message)
                    }
                }
                .padding()
            }
            .navigationTitle("Rectangle Detection")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $cameraService.showImagePicker) {
            ImagePicker(sourceType: cameraService.sourceType, imagePicker: cameraService.imagePicker)
        }
        .alert("Permission Required", isPresented: $cameraService.showPermissionAlert) {
            Button("OK") { }
        } message: {
            Text(cameraService.permissionAlertMessage)
        }
    }
    
    // MARK: - Subviews
    private func RectangleImageSection(image: UIImage, rectangles: [RectangleResult]) -> some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                // Rectangle overlays
                ForEach(rectangles) { rectangle in
                    Rectangle()
                        .stroke(Color.red, lineWidth: 3)
                        .frame(
                            width: rectangle.boundingBox.width * 300,
                            height: rectangle.boundingBox.height * 300
                        )
                        .position(
                            x: rectangle.boundingBox.midX * 300,
                            y: rectangle.boundingBox.midY * 300
                        )
                }
            }
            
            Button("Clear Image") {
                cameraService.clearCapturedImage()
                visionService.resetResults()
            }
            .foregroundColor(.red)
            .padding(.top, 8)
        }
    }
    
    private func PlaceholderSection() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.dashed")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("No Image Selected")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Take a photo or select from library to detect rectangles")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func ActionButtonsSection() -> some View {
        HStack(spacing: 16) {
            Button(action: {
                cameraService.openCamera()
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text("Camera")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button(action: {
                cameraService.openPhotoLibrary()
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Library")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    private func RectangleResultsSection() -> some View {
        VStack(spacing: 16) {
            Text("Detected Rectangles")
                .font(.headline)
            
            ForEach(Array(visionService.rectangleResults.enumerated()), id: \.element.id) { index, rectangle in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Rectangle \(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("Confidence: \(String(format: "%.1f%%", rectangle.confidence * 100))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Position: (\(String(format: "%.2f", rectangle.boundingBox.origin.x)), \(String(format: "%.2f", rectangle.boundingBox.origin.y)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Size: \(String(format: "%.2f", rectangle.boundingBox.width)) × \(String(format: "%.2f", rectangle.boundingBox.height))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: rectangle.confidence)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private func ErrorSection(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    RectangleDetectionView(
        visionService: VisionService(),
        cameraService: CameraService()
    )
}
