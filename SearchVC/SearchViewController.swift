//
//  SearchViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 11.01.2024.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchTopBar: CustomSearchAndSortField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var postsArray = [ReceivedAllPosts]()
    private var firstOpen = true
    var sortedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.hidesWhenStopped = true
        view.backgroundColor = .darkGray
        setupGesture()
        setupTableView()
        getAllPosts()
        setupCollectionView()
        searchTopBar.collectionView = collectionView
        searchTopBar.tableView = self.tableView
        searchTopBar.viewController = (nil, self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstOpen {
            firstOpen = false
        }
    }

}
