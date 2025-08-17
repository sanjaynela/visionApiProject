import SwiftUI

struct TextRecognitionView: View {
    @ObservedObject var visionService: VisionService
    @ObservedObject var cameraService: CameraService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Section
                    if let image = cameraService.capturedImage {
                        ImageSection(image: image)
                    } else {
                        PlaceholderSection()
                    }
                    
                    // Action Buttons
                    ActionButtonsSection()
                    
                    // Results Section
                    if case .processing = visionService.processingState {
                        ProgressView("Processing text...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let textResults = visionService.textResults {
                        ResultsSection(textResults: textResults)
                    } else if case .error(let message) = visionService.processingState {
                        ErrorSection(message: message)
                    }
                }
                .padding()
            }
            .navigationTitle("Text Recognition")
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
    private func ImageSection(image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(12)
                .shadow(radius: 4)
            
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
            Image(systemName: "text.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Image Selected")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Take a photo or select from library to recognize text")
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
    
    private func ResultsSection(textResults: TextRecognitionResult) -> some View {
        VStack(spacing: 20) {
            // Processing time
            HStack {
                Image(systemName: "clock")
                Text("Processing time: \(String(format: "%.2f", textResults.processingTime))s")
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Confidence Chart
            ConfidenceChart(data: textResults.texts)
            
            // Text List
            VStack(alignment: .leading, spacing: 12) {
                Text("Detected Text")
                    .font(.headline)
                
                ForEach(textResults.texts) { textItem in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(textItem.text)
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        HStack {
                            Text("Confidence: \(String(format: "%.1f%%", textItem.confidence * 100))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            ProgressView(value: textItem.confidence)
                                .frame(width: 60)
                        }
                    }
                }
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

// MARK: - Image Picker Wrapper
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let imagePicker: UIImagePickerController
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    TextRecognitionView(
        visionService: VisionService(),
        cameraService: CameraService()
    )
}
