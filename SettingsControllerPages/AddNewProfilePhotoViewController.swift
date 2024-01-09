//
//  AddNewProfilePhotoViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 05.01.2024.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class AddNewProfilePhotoViewController: UIViewController {
    @IBOutlet weak var topBar: AddNewPhotoTopBar!
    @IBOutlet weak var previewProfileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
        self.previewProfileImage.layer.cornerRadius = self.previewProfileImage.bounds.width / 2
        self.previewProfileImage.layer.masksToBounds = true
    }
    
    @IBAction func makePhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        configureImagePicker()
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        let uuid = UserAuthData.shared.uid!
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photosRef = storageRef.child("media/profilePhotos")
        if let imageData = previewProfileImage.image?.jpegData(compressionQuality: 0.8) {
            let imageRef = photosRef.child("\(String(describing: uuid)).jpg")
            FireLoadData.shared.uploadProfileImage(reference: imageRef, data: imageData) { result in
                switch result {
                case .success(_):
                    UserAuthData.shared.profilePhoto = UIImage(data: imageData)
                    let db = Firestore.firestore()
                    FireLoadData.shared.downloadURLImage(imageReference: imageRef) { result in
                        switch result {
                        case .success(let url):
                            let imageURL = ["imageURL" : url.absoluteString]
                            FireLoadData.shared.loadPhotoToCurrentUserData(db: db, requestData: imageURL) { error in
                                if let error {
                                    print(error.localizedDescription)
                                }
                            }
                        case .failure(let error):
                            print(error.localizedDescription) // TODO: - alert
                        }
                    }
                    self.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print(error.localizedDescription) //TODO: - alert
                }
            }
        }
    }
    
    private func handleButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

}

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
