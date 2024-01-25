//
//  HomeController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.12.2023.
//

import UIKit

class HomeController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTopBar: CustomSearchAndSortField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var refreshControl = UIRefreshControl()
    
    static let shared = HomeController()
    var postsArray = [ReceivedAllPosts]()
    private var firstOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setup()
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
        } else {
            getAllPosts()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchTopBar.collectionView = nil
        searchTopBar.tableView = nil
        searchTopBar.viewController = nil
        postsArray.removeAll()
    }
}

