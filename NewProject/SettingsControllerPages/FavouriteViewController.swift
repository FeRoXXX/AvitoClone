//
//  FavouritesViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 22.01.2024.
//

import UIKit

class FavouriteViewController: UIViewController {
    @IBOutlet weak var topBar: UniversalTopBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var postsArray = [ReceivedAllPosts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopBar()
        setupCollection()
        getAllPosts()
        view.backgroundColor = .darkGray
        loadingIndicator.hidesWhenStopped = true
    }

}
