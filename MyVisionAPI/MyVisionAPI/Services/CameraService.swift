import Foundation
import UIKit
import AVFoundation
import Photos

class CameraService: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isCameraAuthorized = false
    @Published var isPhotoLibraryAuthorized = false
    @Published var showImagePicker = false
    @Published var showCamera = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    
    let imagePicker = UIImagePickerController()
    
    override init() {
        super.init()
        checkPermissions()
        setupImagePicker()
    }
    
    // MARK: - Permissions
    func checkPermissions() {
        checkCameraPermission()
        checkPhotoLibraryPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isCameraAuthorized = granted
                }
            }
        default:
            isCameraAuthorized = false
        }
    }
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            isPhotoLibraryAuthorized = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.isPhotoLibraryAuthorized = (status == .authorized || status == .limited)
                }
            }
        default:
            isPhotoLibraryAuthorized = false
        }
    }
    
    // MARK: - Image Picker Setup
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    // MARK: - Actions
    func openCamera() {
        guard isCameraAuthorized else {
            requestCameraPermission()
            return
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceType = .camera
            showImagePicker = true
        }
    }
    
    func openPhotoLibrary() {
        guard isPhotoLibraryAuthorized else {
            permissionAlertMessage = "Photo library access is required. Please add NSPhotoLibraryUsageDescription to your Info.plist file in Xcode."
            showPermissionAlert = true
            return
        }
        
        sourceType = .photoLibrary
        showImagePicker = true
    }
    
    // MARK: - Permission Requests
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isCameraAuthorized = granted
                if granted {
                    self?.sourceType = .camera
                    self?.showImagePicker = true
                }
            }
        }
    }
    
    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.isPhotoLibraryAuthorized = (status == .authorized || status == .limited)
                if self?.isPhotoLibraryAuthorized == true {
                    self?.openPhotoLibrary()
                }
            }
        }
    }
    
    // MARK: - Utility
    func clearCapturedImage() {
        capturedImage = nil
        showImagePicker = false
        showCamera = false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CameraService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            capturedImage = image
        } else if let image = info[.originalImage] as? UIImage {
            capturedImage = image
        }
        
        picker.dismiss(animated: true)
        showCamera = false
        showImagePicker = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        showCamera = false
        showImagePicker = false
    }
}
