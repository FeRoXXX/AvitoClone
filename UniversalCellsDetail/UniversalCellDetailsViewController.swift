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
    var uuid : UUID?
    var currentPost : ReceivedCurrentPost?
    var imageArray = [UIImage]()
    var indexImage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPostFromFirebase()
        imageView.isUserInteractionEnabled = true
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
        
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGestureRight.direction = .right
        swipeGestureLeft.direction = .left
        imageView.addGestureRecognizer(swipeGestureLeft)
        imageView.addGestureRecognizer(swipeGestureRight)
        
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
        imageView.image = imageArray[indexImage]
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
