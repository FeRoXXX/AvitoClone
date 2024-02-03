//
//  HomeController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit
import SDWebImage

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
        guard let posts = posts,
              posts.postsArray.count > 0 else { return cell}
        
        cell.publicationName.text = posts.postsArray[indexPath.row].name
        cell.image = posts.postsArray[indexPath.row].imageURL
        cell.publicationPrice.text = posts.postsArray[indexPath.row].price
        cell.publicationTime.text = posts.postsArray[indexPath.row].date
        cell.sellerAdress.text = posts.postsArray[indexPath.row].address
        cell.handleTapped = { [weak self] in
            self?.likeButtonTapped(currentIndex: indexPath.row, indexPath: indexPath)
        }
        if let userUUID = UserAuthData.shared.uid,
           let postUUID = posts.postsArray[indexPath.row].userUUID,
           userUUID == postUUID{
            cell.likeImage.isHidden = true
        } else {
            cell.likeImage.isHidden = false
        }
        if cell.likeImage.isHidden == false,
           let checkedLike = posts.postsArray[indexPath.row].checkedLikeImage {
            if checkedLike {
                cell.likeImage.image = UIImage(systemName: "heart.fill")
            } else {
                cell.likeImage.image = UIImage(systemName: "heart")
            }
        }
        
        return cell
    }
    
    func likeButtonTapped(currentIndex: Int, indexPath: IndexPath) {
        guard let posts = posts else { return }
        Task {
            do {
                try await posts.addLikeToPublication(index: currentIndex)
                collectionView.reloadItems(at: [indexPath])
            } catch {
                print("error")
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = posts,
              posts.postsArray.count > 0 else { return 0 }
        return posts.postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let posts = posts else { return }
        let detailsViewController = UniversalCellDetailsViewController()
        detailsViewController.uuid = posts.postsArray[indexPath.row].uuid
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? HomeCollectionViewCell
        cell?.publicationImage.image = UIImage(systemName: "heart")
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? HomeCollectionViewCell
        Task {
            try await cell?.setupImage()
        }
    }
}

//MARK: - Get all posts from firebase
extension HomeController {
    
    func getAllPosts() {
        self.loadingIndicator.startAnimating()
        posts = nil
        Task(priority: .high) {
            posts = try await ReceivedAllPosts()
            collectionView.reloadData()
            self.loadingIndicator.stopAnimating()
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
            var newVC : SearchViewController? = SearchViewController()
            //TODO: - ARRAY WITH Search Results
            newVC!.sortedText = "Search"
            navigationController.pushViewController(newVC!, animated: true)
            newVC = nil
        }
        searchTopBar.searchTextField.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - go to new vc
extension HomeController {
    func goToNewViewControllerFromSearchBar() {
        if let navigationController = self.navigationController {
            var newVC : SearchViewController? = SearchViewController()
            if let text = self.searchTopBar.searchTextField.text {
                newVC!.sortedText = text
            }
            navigationController.pushViewController(newVC!, animated: true)
            newVC = nil
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
        getAllPosts()
        self.refreshControl.endRefreshing()
    }
    
    @objc func refreshData() {
        updateData()
    }
}

