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
    var universalCellDetailsViewController: UniversalCellDetailsViewController?
    var uuid: UUID?
    
    var imageArray = [UIImage]()
    var indexImage: Int = 0
    var postsArray = [UserPosts]()
    var currentPost : ReceivedCurrentPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBar.topBarText.text = "Добавить товар"
        setupBackButton()
        
        productInformationTextView.layer.cornerRadius = 5
        setupGesture()
       
        topBar.firstButton.isHidden = true
        topBar.secondButton.isHidden = true
        if universalCellDetailsViewController != nil {
            setupPrevValues()
        }
    }
    
    @objc func choosePhoto() {
        configureImagePicker()
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard imageArray.count > 0 else { return } //TODO: - Alert
        guard let productName = productNameTextField.text else { return } //TODO: - Alert
        guard let information = productInformationTextView.text else { return } //TODO: - Alert
        guard let price = priceTextField.text else { return } //TODO: - Alert
        guard let userID = UserAuthData.shared.uid else { return }
        var post : UploadNewPost?
        if let uuid = self.uuid {
            post = UploadNewPost(name: productName, information: information, price: price, imagesArray: imageArray, category: "products", uuidOpt: uuid)
        } else {
            post = UploadNewPost(name: productName, information: information, price: price, imagesArray: imageArray, category: "products")
        }
        guard let post = post else { return }
        var downloadURL = [String]()
        
        post.sendImageToStorage(userID: userID) { status, result in
            if status {
                downloadURL.append(result)
                Task {
                    do {
                        try await post.sendPostDataToFirebase(downloadURL: downloadURL, userID: userID)
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
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

//MARK: - configure PHPicker
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

//MARK: - setup Gesture
extension ProductsViewController {
    func setupGesture() {
        imageView.isUserInteractionEnabled = true
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
}

//MARK: - setup back button
extension ProductsViewController {
    
    func setupBackButton() {
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
    }
    
    private func handleButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}

extension ProductsViewController {
    
    func setupPrevValues() {
        guard let uuid = self.uuid else {
            GlobalFunctions.alert(vc: self, title: "Ошибка", message: "Произошла ошибка попробуйте позднее")
            return
        }
        Task {
            do {
                currentPost = try await ReceivedCurrentPost.init(uuidCurrentPost: uuid)
                guard currentPost != nil else { return }
                currentPost!.dictionaryToVariables(completion: { result in
                    switch result {
                    case .success(_):
                        if let name = self.currentPost!.name {
                            self.productNameTextField.text = name
                        }
                        if let price = self.currentPost!.price {
                            self.priceTextField.text = price
                        }
                        if let information = self.currentPost!.information {
                            self.productInformationTextView.text = information
                        }
                        self.imageArray = self.currentPost!.image
                        self.imageView.image = self.currentPost!.image.first
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                })
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
