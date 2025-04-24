//
//  ImagePickerImpl.swift
//  ImagePicker
//
//  Created by Andrey Vasilencko on 24.04.2025.
//

import Foundation
import Photos
import PhotosUI

@objc public class ImagePickerImpl: NSObject {
    
    var onImagePickedSuccess: ((String)-> Void)?
    var onImagePickerError: ((String)-> Void)?
    
    enum ImagePickedResult {
        case success(String)
        case error(String)
    }
    
    let rootVc = UIApplication.shared.connectedScenes
        .compactMap({$0 as? UIWindowScene})
        .flatMap(\.windows)
        .first(where: {$0.isKeyWindow})?.rootViewController;
    
    @objc public func getPermissionStatus() -> String {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite);
        return parseStatus(status);
    }

    @objc public func requestPermission(
        onStatusChanged: @escaping (String) -> Void
    ) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) {[weak self] status in
            guard let self else { return }
            onStatusChanged(self.parseStatus(status))
        }
        
    }

    @objc public func pickImage(onSuccess: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        guard self.onImagePickedSuccess == nil, self.onImagePickerError == nil else {
            onError("already picking image")
            return
        }
        
        self.onImagePickedSuccess = onSuccess
        self.onImagePickerError = onError
        
        
        guard let rootVc else {
            onImagePicked(result: .error("Failed to pick an Image"))
            return
        }
        var config = PHPickerConfiguration(photoLibrary: .shared());
        config.selectionLimit = 1
        config.filter = .images
        
      
        DispatchQueue.main.async {
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            rootVc.present(picker, animated: true)
        }
        
        
    }
    
    private func parseStatus(_ status: PHAuthorizationStatus) -> String {
        switch status {
        case .limited, .authorized:
            return "authorized"
        case .denied, .restricted:
            return "unauthorized"
        case .notDetermined:
            return "notDetermined"
        @unknown default:
            return "unkown"
        }
    }
    
    
    
    private func onImagePicked(result: ImagePickedResult) {
        guard let onImagePickerError, let onImagePickedSuccess else { return }
        switch result {
        case .success(let uri):
            onImagePickedSuccess(uri)
        case .error(let error):
            onImagePickerError(error)
        }
        self.onImagePickerError = nil
        self.onImagePickedSuccess = nil
    }

}

extension ImagePickerImpl : PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let rootVc else {
            onImagePicked(result: .error("Failed to pick Image"))
            return
        }
        
        rootVc.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        else {
            onImagePicked(result: .error("Failed to pick image."))
            return
        }
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) {[weak self] url, error in
            guard let self else {return}
            guard let url, error == nil else {
                self.onImagePicked(result: .error("Failed to pick image."))
                return
            }
            
            let fileManager = FileManager.default
            let newUrl = fileManager.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            
            do {
                if fileManager.fileExists(atPath: newUrl.path) {
                    try fileManager.removeItem(at: newUrl)
                }
                try fileManager.copyItem(at: url, to: newUrl)
            } catch {
                self.onImagePicked(result: .error("Failed to pick image"))
                return
            }
            self.onImagePicked(result: .success(newUrl.absoluteString))
        }
    }
    
    
}
