import SwiftUI

struct BodyPoseView: View {
    @ObservedObject var visionService: VisionService
    @ObservedObject var cameraService: CameraService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Section with Pose Overlay
                    if let image = cameraService.capturedImage {
                        PoseImageSection(image: image, poseResults: visionService.bodyPoseResults)
                    } else {
                        PlaceholderSection()
                    }
                    
                    // Action Buttons
                    ActionButtonsSection()
                    
                    // Results Section
                    if case .processing = visionService.processingState {
                        ProgressView("Detecting body pose...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let poseResults = visionService.bodyPoseResults {
                        PoseResultsSection(poseResults: poseResults)
                    } else if case .error(let message) = visionService.processingState {
                        ErrorSection(message: message)
                    }
                }
                .padding()
            }
            .navigationTitle("Body Pose Detection")
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
    private func PoseImageSection(image: UIImage, poseResults: BodyPoseResult?) -> some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                // Pose point overlays
                if let poseResults = poseResults {
                    ForEach(poseResults.points) { point in
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .position(
                                x: point.location.x * 300,
                                y: point.location.y * 300
                            )
                    }
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
            Image(systemName: "figure.stand")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("No Image Selected")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Take a photo or select from library to detect body pose")
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
    
    private func PoseResultsSection(poseResults: BodyPoseResult) -> some View {
        VStack(spacing: 16) {
            // Processing time
            HStack {
                Image(systemName: "clock")
                Text("Processing time: \(String(format: "%.2f", poseResults.processingTime))s")
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Summary stats
            HStack {
                StatCard(
                    title: "Joints Detected",
                    value: "\(poseResults.points.count)",
                    color: .green
                )
                
                StatCard(
                    title: "High Confidence",
                    value: "\(poseResults.points.filter { $0.confidence > 0.8 }.count)",
                    color: .blue
                )
                
                StatCard(
                    title: "Avg Confidence",
                    value: String(format: "%.1f%%", poseResults.points.map(\.confidence).reduce(0, +) / Double(poseResults.points.count) * 100),
                    color: .orange
                )
            }
            
            // Joint details
            VStack(alignment: .leading, spacing: 12) {
                Text("Detected Joints")
                    .font(.headline)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(poseResults.points.sorted { $0.confidence > $1.confidence }) { point in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(point.jointName.replacingOccurrences(of: "VNHumanBodyPoseObservation.JointName.", with: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Confidence: \(String(format: "%.1f%%", point.confidence * 100))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: point.confidence)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
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

#Preview {
    BodyPoseView(
        visionService: VisionService(),
        cameraService: CameraService()
    )
}
