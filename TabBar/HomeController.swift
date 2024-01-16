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
    var refreshControl = UIRefreshControl()
    
    static let shared = HomeController()
    var postsArray = [ReceivedAllPosts]()
    private var firstOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setup()
        setupTableView()
        getAllPosts()
        searchTopBar.collectionView = collectionView
        searchTopBar.tableView = self.tableView
        searchTopBar.viewController = (self, nil)
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstOpen {
            firstOpen = false
        } else {
            postsArray.removeAll()
            getAllPosts()
        }
    }
}

