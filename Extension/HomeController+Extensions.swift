//
//  HomeController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit

//MARK: - Setup collectionView
extension HomeController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .darkGray
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        guard postsArray.count > 0 else { return cell }
        
        cell.publicationName.text = postsArray[indexPath.row].name
        cell.publicationImage.image = postsArray[indexPath.row].image
        cell.publicationPrice.text = postsArray[indexPath.row].price
        cell.publicationTime.text = postsArray[indexPath.row].date
        cell.sellerAdress.text = postsArray[indexPath.row].address
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard postsArray.count > 0 else { return 0 }
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsViewController = UniversalCellDetailsViewController()
        detailsViewController.uuid = postsArray[indexPath.row].uuid
        hidesBottomBarWhenPushed = true
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailsViewController, animated: true)
        }
        hidesBottomBarWhenPushed = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacingBetweenCells: CGFloat = 10.0
        let cellWidth = (collectionViewWidth - spacingBetweenCells) / 2.0
        return CGSize(width: cellWidth, height: 260)
    }
}

//MARK: - Get all posts from firebase
extension HomeController {
    
    func getAllPosts() {
        Task(priority: .high) {
            do {
                let posts = try await ReceivedAllPosts.init()
                guard posts.data.count > 0 else { return }
                for postIndex in (0...posts.data.count - 1) {
                    let newPost = ReceivedAllPosts(postData: posts.data)
                    newPost.dictionaryToVariables(index: postIndex) { result in
                        switch result {
                        case .success(_):
                            self.postsArray.append(newPost)
                            self.collectionView.reloadData()
                            
                        case .failure(let failure):
                            print(failure.localizedDescription)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - TableView
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .darkGray
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellStyle = cell.defaultContentConfiguration()
        cellStyle.text = "Search"
        cell.backgroundColor = .darkGray
        cell.tintColor = .black
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = cellStyle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navigationController = self.navigationController {
            let newVC = SearchViewController()
            //TODO: - ARRAY WITH Search Results
            newVC.sortedText = "Search"
            navigationController.pushViewController(newVC, animated: true)
        }
        searchTopBar.searchTextField.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - go to new vc
extension HomeController {
    func goToNewViewControllerFromSearchBar() {
        if let navigationController = self.navigationController {
            let newVC = SearchViewController()
            if let text = self.searchTopBar.searchTextField.text {
                newVC.sortedText = text
            }
            navigationController.pushViewController(newVC, animated: true)
        }
    }
}

//MARK: - setup refresh control
extension HomeController {
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        scrollView.refreshControl = refreshControl
    }
    
    func updateData() {
        postsArray.removeAll()
        getAllPosts()
        self.refreshControl.endRefreshing()
    }
    
    @objc func refreshData() {
        updateData()
    }
}

