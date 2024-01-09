//
//  ProductsViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.01.2024.
//

import UIKit
import PhotosUI

class ProductsViewController: UIViewController {
    
    @IBOutlet weak var topBar: UniversalTopBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productInformationTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    
    var imageArray = [UIImage]()
    var indexImage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true

        topBar.topBarText.text = "Добавить товар"
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
        productInformationTextView.layer.cornerRadius = 5
        
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGestureRight.direction = .right
        swipeGestureLeft.direction = .left
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(choosePhoto))
        
        imageView.addGestureRecognizer(tapGesture)
        imageView.addGestureRecognizer(swipeGestureRight)
        imageView.addGestureRecognizer(swipeGestureLeft)
        
        updateImage()
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            indexImage = (indexImage + 1) % imageArray.count
        }
        if gesture.direction == .right {
            indexImage = (indexImage - 1 + imageArray.count) % imageArray.count
        }
        
        updateImage()
    }
    
    func updateImage() {
        guard imageArray.count != 0 else { return }
        imageView.image = imageArray[indexImage]
    }
    
    @objc func choosePhoto() {
        configureImagePicker()
    }
    
    private func handleButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard imageArray.count > 0 else { return } //TODO: - Alert
        guard let productName = productNameTextField.text else { return } //TODO: - Alert
        guard let information = productInformationTextView.text else { return } //TODO: - Alert
        guard let price = priceTextField.text else { return } //TODO: - Alert
        guard let userID = UserAuthData.shared.uid else { return }
        let post = UploadNewPost(name: productName, information: information, price: price, imagesArray: imageArray, category: "products")
        var downloadURL = [String]()
        
        post.sendImageToStorage(userID: userID) { status, result in
            if status {
                downloadURL.append(result)
                Task {
                    do {
                        try await post.sendPostDataToFirebase(downloadURL: downloadURL, userID: userID)
                        let mainScreen = MainTabBarViewController()
                        mainScreen.modalPresentationStyle = .fullScreen
                        mainScreen.modalTransitionStyle = .flipHorizontal
                        self.present(mainScreen, animated: true)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } else {
                print(result)
            }
        }
    }
}

extension ProductsViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        imageArray.removeAll()
        indexImage = 0
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.imageArray.append(image)
                        self.updateImage()
                    }
                }
            }
        }
    }
    
    func configureImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 10
        configuration.filter = .images
        
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        present(pickerViewController, animated: true)
    }
}
