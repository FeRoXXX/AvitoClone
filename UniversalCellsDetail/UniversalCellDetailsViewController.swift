//
//  UniversalCellDetailsViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit

class UniversalCellDetailsViewController: UIViewController {
    @IBOutlet weak var topBar: UniversalTopBar!
    @IBOutlet weak var publicationPrice: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var publicationName: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var aboutPublication: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var cartButton: UIButton!
    var buttonFlag: Bool?
    var uuid : UUID?
    var currentPost : ReceivedCurrentPost?
    var imageArray = [UIImage]()
    var indexImage: Int = 0
    var scrollAndCollectionVC : ScrollAndCollectionViewForAddNewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPostFromFirebase()
        imageView.isUserInteractionEnabled = true
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
        if buttonFlag != nil, buttonFlag! {
            topBar.firstButtonTapped = { [weak self] in
                self?.handleCorrectButtonTapped()
            }
            topBar.secondButtonTapped = { [weak self] in
                self?.handleDeleteButtonTapped()
            }
            topBar.firstButton.setImage(UIImage(systemName: "square.and.pencil.circle"), for: .normal)
            topBar.secondButton.setImage(UIImage(systemName: "trash"), for: .normal)
        } else {
            topBar.firstButton.isHidden = true
            topBar.secondButton.isHidden = true
        }
        topBar.topBarText.text = "Просмотр объявления"
        
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGestureRight.direction = .right
        swipeGestureLeft.direction = .left
        imageView.addGestureRecognizer(swipeGestureLeft)
        imageView.addGestureRecognizer(swipeGestureRight)
    }
    
    private func handleCorrectButtonTapped() {
        let productsViewController = ProductsViewController()
        productsViewController.universalCellDetailsViewController = self
        productsViewController.uuid = self.uuid
        hidesBottomBarWhenPushed = true
        if let navigationController = self.navigationController {
            navigationController.pushViewController(productsViewController, animated: true)
        }
    }
    
    private func handleDeleteButtonTapped() {
        Task {
            do {
                try await currentPost?.deletePost()
                if let navigationController = self.navigationController {
                    self.scrollAndCollectionVC?.loadData()
                    navigationController.popViewController(animated: true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleButtonTapped() {
        self.navigationController?.popViewController(animated: true)
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
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageView.image = self.imageArray[self.indexImage]
        }, completion: nil)
    }
    
    func getPostFromFirebase() {
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
                            self.publicationName.text = name
                        }
                        if let price = self.currentPost!.price {
                            self.publicationPrice.text = price
                        }
                        if let information = self.currentPost!.information {
                            self.aboutPublication.text = information
                        }
                        if let city = self.currentPost!.address {
                            self.city.text = city
                        }
                        if let date = self.currentPost!.date {
                            self.dateLabel.text = date
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
    
    @IBAction func callPressed(_ sender: Any) {
        if let number = self.currentPost!.number {
            self.callButton.setTitle(number, for: .normal)
        }
    }
    
    @IBAction func addToCartClicked(_ sender: Any) {
    }
    
}
