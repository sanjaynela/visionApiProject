import SwiftUI

struct BarcodeDetectionView: View {
    @ObservedObject var visionService: VisionService
    @ObservedObject var cameraService: CameraService
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Section with Barcode Overlay
                    if let image = cameraService.capturedImage {
                        BarcodeImageSection(image: image, barcodes: visionService.barcodeResults)
                    } else {
                        PlaceholderSection()
                    }
                    
                    // Action Buttons
                    ActionButtonsSection()
                    
                    // Results Section
                    if case .processing = visionService.processingState {
                        ProgressView("Detecting barcodes...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if !visionService.barcodeResults.isEmpty {
                        BarcodeResultsSection()
                    } else if case .error(let message) = visionService.processingState {
                        ErrorSection(message: message)
                    }
                }
                .padding()
            }
            .navigationTitle("Barcode Detection")
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
    private func BarcodeImageSection(image: UIImage, barcodes: [BarcodeResult]) -> some View {
        VStack {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                
                // Barcode overlays
                ForEach(barcodes) { barcode in
                    Rectangle()
                        .stroke(Color.purple, lineWidth: 3)
                        .frame(
                            width: barcode.boundingBox.width * 300,
                            height: barcode.boundingBox.height * 300
                        )
                        .position(
                            x: barcode.boundingBox.midX * 300,
                            y: barcode.boundingBox.midY * 300
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
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("No Image Selected")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Take a photo or select from library to detect barcodes")
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
    
    private func BarcodeResultsSection() -> some View {
        VStack(spacing: 16) {
            Text("Detected Barcodes")
                .font(.headline)
            
            ForEach(Array(visionService.barcodeResults.enumerated()), id: \.element.id) { index, barcode in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Barcode \(index + 1)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(barcode.symbology.replacingOccurrences(of: "VNBarcodeSymbology.", with: ""))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payload:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(barcode.payload)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .textSelection(.enabled)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Position: (\(String(format: "%.2f", barcode.boundingBox.origin.x)), \(String(format: "%.2f", barcode.boundingBox.origin.y)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Size: \(String(format: "%.2f", barcode.boundingBox.width)) × \(String(format: "%.2f", barcode.boundingBox.height))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
    BarcodeDetectionView(
        visionService: VisionService(),
        cameraService: CameraService()
    )
}
