//
//  SearchViewController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit

//MARK: - TableView
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .darkGray
        self.tableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellStyle = cell.defaultContentConfiguration()
        cellStyle.text = "Search"
        cell.backgroundColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = cellStyle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navigationController = navigationController {
            let newVC = SearchViewController()
            if let text = self.searchTopBar.searchTextField.text {
                newVC.sortedText = text
            }
            navigationController.pushViewController(newVC, animated: true)
        }
        searchTopBar.searchTextField.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - CollectionView
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = .darkGray
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = posts,
              posts.postsArray.count > 0 else { return 0 }
        return posts.postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        guard let posts = posts,
              posts.postsArray.count > 0 else { return cell }
        
        cell.publicationName.text = posts.postsArray[indexPath.row].name
        cell.image = posts.postsArray[indexPath.row].imageURL
        cell.publicationPrice.text = posts.postsArray[indexPath.row].price
        cell.publicationTime.text = posts.postsArray[indexPath.row].date
        cell.sellerAdress.text = posts.postsArray[indexPath.row].address
        cell.handleTapped = { [weak self] in
            guard let self = self else {
                return
            }
            self.likeButtonTapped(currentIndex: indexPath.row, indexPath: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacingBetweenCells: CGFloat = 10.0
        let cellWidth = (collectionViewWidth - spacingBetweenCells) / 2.0
        return CGSize(width: cellWidth, height: 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let posts = posts else { return }
        let detailsViewController = UniversalCellDetailsViewController()
        detailsViewController.uuid = posts.postsArray[indexPath.row].uuid
        hidesBottomBarWhenPushed = true
        
        if let navigationController = navigationController {
            navigationController.pushViewController(detailsViewController, animated: true)
        }
        hidesBottomBarWhenPushed = false
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? HomeCollectionViewCell
        Task {
            try await cell?.setupImage()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? HomeCollectionViewCell
        cell?.publicationImage.image = UIImage(systemName: "heart")
    }
}

//MARK: - Swipe Gesture for popBack
extension SearchViewController: UIGestureRecognizerDelegate {
    func setupGesture() {
        if let navigationController = navigationController {
            navigationController.interactivePopGestureRecognizer?.delegate = self
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - Get all posts from firebase filtered
extension SearchViewController {
    
    func getAllPosts() {
        loadingIndicator.startAnimating()
        Task(priority: .high) {
            posts = try await ReceivedAllPosts(sortString: sortedText)
            print("compiled")
            collectionView.reloadData()
            loadingIndicator.stopAnimating()
        }
    }
}

//MARK: - setup search top bar
extension SearchViewController {
    func setupSearchTopBar() {
        searchTopBar.collectionView = collectionView
        searchTopBar.tableView = self.tableView
        searchTopBar.viewController = self
    }
}
