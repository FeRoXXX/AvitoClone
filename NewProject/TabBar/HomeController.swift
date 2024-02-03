//
//  HomeController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.12.2023.
//

import UIKit
import SDWebImage

class HomeController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTopBar: CustomSearchAndSortField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var refreshControl = UIRefreshControl()
    
    var posts : ReceivedAllPosts?
    var firstOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        getAllPosts()
        setupTableView()
        setupRefreshControl()
        self.loadingIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchTopBar.collectionView = collectionView
        searchTopBar.tableView = self.tableView
        searchTopBar.viewController = self
        if firstOpen {
            firstOpen = false
            setup()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //postsArray.removeAll()
        guard let posts = posts else { return }
//        for index in 0..<posts.postsArray.count {
//            let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? HomeCollectionViewCell
//            cell?.publicationImage.image = UIImage(systemName: "heart")
//            collectionView.reloadData()
//        }
    }
    deinit {
        print("HomeVC is deinited")
    }
}

