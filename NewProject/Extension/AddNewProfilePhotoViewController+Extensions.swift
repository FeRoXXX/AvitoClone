//
//  AddNewProfilePhotoViewController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 23.01.2024.
//

import UIKit
import PhotosUI

//MARK: - make photo and put on imageView
extension AddNewProfilePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        previewProfileImage.image = image
    }
}

//MARK: - load image from library
extension AddNewProfilePhotoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if let item = results.first?.itemProvider {
            if item.canLoadObject(ofClass: UIImage.self){
                item.loadObject(ofClass: UIImage.self) { image, error in
                    if let error {
                        print(error.localizedDescription)
                    }
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.previewProfileImage.image = image
                        }
                    }
                }
            }
        }
    }
    
    func configureImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        present(pickerViewController, animated: true)
    }
}
