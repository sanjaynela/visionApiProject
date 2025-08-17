//
//  ContentView.swift
//  MyVisionAPI
//
//  Created by Sanjay Nelagadde on 8/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var visionService = VisionService()
    @StateObject private var cameraService = CameraService()
    
    var body: some View {
        TabView {
            TextRecognitionView(visionService: visionService, cameraService: cameraService)
                .tabItem {
                    Image(systemName: "text.viewfinder")
                    Text("Text Recognition")
                }
            
            RectangleDetectionView(visionService: visionService, cameraService: cameraService)
                .tabItem {
                    Image(systemName: "rectangle.dashed")
                    Text("Rectangle Detection")
                }
            
            BodyPoseView(visionService: visionService, cameraService: cameraService)
                .tabItem {
                    Image(systemName: "figure.stand")
                    Text("Body Pose")
                }
            
            BarcodeDetectionView(visionService: visionService, cameraService: cameraService)
                .tabItem {
                    Image(systemName: "barcode.viewfinder")
                    Text("Barcode Detection")
                }
        }
        .onChange(of: cameraService.capturedImage) { newImage in
            if let image = newImage {
                processImage(image)
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        // Reset previous results
        visionService.resetResults()
        
        // Get the current tab to determine which Vision API to use
        // This is a simplified approach - in a real app you might want to track the active tab
        // For now, we'll process with all available APIs
        visionService.processingState = .processing
        
        // Process with all Vision APIs
        visionService.recognizeText(from: image) { _ in }
        visionService.detectRectangles(from: image) { _ in }
        visionService.detectBodyPose(from: image) { _ in }
        visionService.detectBarcodes(from: image) { _ in }
    }
}

#Preview {
    ContentView()
}
