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
            guard let self = self else {
                return
            }
            self.handleButtonTapped()
        }
        previewProfileImage.layer.cornerRadius = previewProfileImage.bounds.width / 2
        previewProfileImage.layer.masksToBounds = true
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
            FireLoadData.shared.uploadProfileImage(reference: imageRef, data: imageData) { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(_):
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
        dismiss(animated: true, completion: nil)
    }

}

