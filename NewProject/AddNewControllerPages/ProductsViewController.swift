//
//  ProductsViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.01.2024.
//

import UIKit
import PhotosUI

class ProductsViewController: UIViewController {
    
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var topBar: UniversalTopBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productInformationTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var nameToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var universalCellDetailsViewController: UniversalCellDetailsViewController?
    var uuid: UUID?
    
    var imageArray = [UIImage]()
    var indexImage: Int = 0
    var postsArray = [UserPosts]()
    var currentPost : ReceivedCurrentPost?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        topBar.topBarText.text = "Добавить товар"
        setupBackButton()
        numberTextField.keyboardType = .numberPad
        
        productInformationTextView.layer.cornerRadius = 5
        setupGesture()
       
        topBar.firstButton.isHidden = true
        topBar.secondButton.isHidden = true
        if universalCellDetailsViewController != nil {
            setupPrevValues()
        }
        setupObserver()
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
        guard let number = numberTextField.text else { return } // TODO: - Alert
        guard let address = addressTextField.text else { return } // TODO: - Alert
        setupNewPost(productName: productName, information: information, price: price, userID: userID, number: number, address: address)
    }
    deinit {
           NotificationCenter.default.removeObserver(self)
       }
}

