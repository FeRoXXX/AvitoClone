//
//  UniversalCellDetailsViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit
import SDWebImage

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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cartButton: UIButton!
    var buttonFlag: Bool?
    var uuid : UUID?
    var post : ReceivedCurrentPost?
    var imageArray = [String]()
    var indexImage: Int = 0
    var scrollAndCollectionVC : ScrollAndCollectionViewForAddNewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.hidesWhenStopped = true
        getPostFromFirebase()
        setupGesture()
        setupTopBar()
        
    }
    
    @IBAction func callPressed(_ sender: Any) {
        guard let post = post,
              let currentPost = post.currentPost,
              let number = currentPost.number else { return }
        self.callButton.setTitle(number, for: .normal)
    }
    
    @IBAction func addToCartClicked(_ sender: Any) {
    }
    
    deinit {
        print("cell details is deinited")
        SDImageCache.shared.clearMemory()
    }
}
