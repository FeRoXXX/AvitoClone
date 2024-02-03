//
//  ProductsViewController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 23.01.2024.
//

import UIKit
import PhotosUI
import SDWebImage

//MARK: - Keyboard load
extension ProductsViewController {
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            UIView.animate(withDuration: 1) {
                self.imageView.alpha = 0
                self.addPhotoLabel.alpha = 0
                self.nameToViewConstraint.priority = UILayoutPriority(1000)
                self.numberToViewConstraint.priority = UILayoutPriority(1000)
                self.productNameTextField.layoutIfNeeded()
            }
            self.imageView.isHidden = true
            self.addPhotoLabel.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.imageView.isHidden = false
        self.addPhotoLabel.isHidden = false
        UIView.animate(withDuration: 1) {
            self.imageView.alpha = 100
            self.addPhotoLabel.alpha = 100
            self.nameToViewConstraint.priority = UILayoutPriority(1)
            self.numberToViewConstraint.priority = UILayoutPriority(1)
            self.productNameTextField.layoutIfNeeded()
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
                        self.indexImage = 0
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
        let tapGestureToView = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        swipeGestureRight.direction = .right
        swipeGestureLeft.direction = .left
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(choosePhoto))
        
        imageView.addGestureRecognizer(tapGesture)
        imageView.addGestureRecognizer(swipeGestureRight)
        imageView.addGestureRecognizer(swipeGestureLeft)
        view.addGestureRecognizer(tapGestureToView)
        
        updateImage()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if imageArray.count > 0 {
            if gesture.direction == .left {
                indexImage = (indexImage + 1) % imageArray.count
            }
            if gesture.direction == .right {
                indexImage = (indexImage - 1 + imageArray.count) % imageArray.count
            }
        } else {
            if gesture.direction == .left {
                indexImage = (indexImage + 1) % imageArrayString.count
            }
            if gesture.direction == .right {
                indexImage = (indexImage - 1 + imageArrayString.count) % imageArrayString.count
            }
        }
        updateImage()
    }
    
    func updateImage() {
        guard imageArrayString.count != 0 else { return }
        if imageArray.count > 0 {
            UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.imageView.image = self.imageArray[self.indexImage]
            }, completion: nil)
        } else {
            UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                DispatchQueue.main.async {
                    guard self.imageArray.count > 0 else { return }
                    SDWebImageManager.shared.loadImage(with: URL(string: self.imageArrayString[self.indexImage]), options: .lowPriority, progress: .none) { image, _, error, _, _, _ in
                        if let image = image {
                            self.imageView.image = self.resizeImageToFullHD(image)
                        }
                    }
                }
            }, completion: nil)
        }
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

//MARK: - setup values from firebase
extension ProductsViewController {
    
    func setupPrevValues() {
        self.activityIndicator.startAnimating()
        guard let uuid = self.uuid else {
            GlobalFunctions.alert(vc: self, title: "Ошибка", message: "Произошла ошибка попробуйте позднее")
            return
        }
        Task {
            do {
                try await post = ReceivedCurrentPost(uuidCurrentPost: uuid)
                guard let post = post,
                      let currentPost = post.currentPost,
                      let name = currentPost.name,
                      let price = currentPost.price,
                      let number = currentPost.number,
                      let information = currentPost.information,
                      let city = currentPost.address,
                      let image = currentPost.image else { return }
                self.productNameTextField.text = name
                self.priceTextField.text = price
                self.productInformationTextView.text = information
                self.numberTextField.text = number
                self.addressTextField.text = city
                for image in image {
                    imageArrayString.append(image)
                }
                DispatchQueue.main.async {
                    guard self.imageArrayString.count > 0 else { return }
                    SDWebImageManager.shared.loadImage(with: URL(string: self.imageArrayString.first!), options: .lowPriority, progress: .none) { image, _, error, _, _, _ in
                        if let image = image {
                            self.imageView.image = self.resizeImageToFullHD(image)
                        }
                    }
                }
                self.activityIndicator.stopAnimating()
            } catch {
                print(error)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func resizeImageToFullHD(_ image: UIImage) -> UIImage? {
        let targetSize = CGSize(width: 640, height: 480)
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
            SDImageCache.shared.clearMemory()
        }
    }
}

//MARK: - request to firebase for save publication
extension ProductsViewController {
    
    func setupNewPost(productName: String, information: String, price: String, userID: String, number: String, address: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM, HH:mm"
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        var post : UploadNewPost?
        if let uuid = self.uuid {
            post = UploadNewPost(name: productName, information: information, price: price, imagesArray: imageArray, category: "products", number: number, date: formattedDate, address: address, uuidOpt: uuid)
        } else {
            post = UploadNewPost(name: productName, information: information, price: price, imagesArray: imageArray, category: "products", number: number, date: formattedDate, address: address)
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

