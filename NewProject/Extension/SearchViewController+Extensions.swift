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
        guard postsArray.count > 0 else { return 0 }
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        guard postsArray.count > 0 else { return cell }
        
        cell.publicationName.text = postsArray[indexPath.row].name
        cell.publicationImage.image = postsArray[indexPath.row].image
        cell.publicationPrice.text = postsArray[indexPath.row].price
        cell.publicationTime.text = postsArray[indexPath.row].date
        cell.sellerAdress.text = postsArray[indexPath.row].address
        cell.handleTapped = { [weak self] in
            self?.likeButtonTapped(currentIndex: indexPath.row, indexPath: indexPath)
        }
        if let userUUID = UserAuthData.shared.uid,
           let postUUID = postsArray[indexPath.row].userUUID,
           userUUID == postUUID{
            cell.likeImage.isHidden = true
        } else {
            cell.likeImage.isHidden = false
        }
        if cell.likeImage.isHidden == false,
           let checkedLike = postsArray[indexPath.row].checkedLikeImage {
            if checkedLike {
                cell.likeImage.image = UIImage(systemName: "heart.fill")
            } else {
                cell.likeImage.image = UIImage(systemName: "heart")
            }
        }
        
        return cell
    }
    
    func likeButtonTapped(currentIndex: Int, indexPath: IndexPath) {
        guard let currentPostUUID = postsArray[currentIndex].uuid,
              let currentUserUUID = UserAuthData.shared.uid else { return }
        Task {
            do {
                try await postsArray[currentIndex].addLikeToPublication(postID: currentPostUUID, userID: currentUserUUID)
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
        let detailsViewController = UniversalCellDetailsViewController()
        detailsViewController.uuid = postsArray[indexPath.row].uuid
        hidesBottomBarWhenPushed = true
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailsViewController, animated: true)
        }
        hidesBottomBarWhenPushed = false
    }
}

//MARK: - Swipe Gesture for popBack
extension SearchViewController: UIGestureRecognizerDelegate {
    func setupGesture() {
        if let navigationController = self.navigationController {
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
        self.loadingIndicator.startAnimating()
        Task(priority: .high) {
            do {
                let posts = try await ReceivedAllPosts.init(text: sortedText)
                guard posts.data.count > 0 else {
                    self.loadingIndicator.stopAnimating()
                    return
                }
                for postIndex in (0...posts.data.count - 1) {
                    let newPost = ReceivedAllPosts(postData: posts.data)
                    newPost.dictionaryToVariables(index: postIndex) { [weak self] result in
                        switch result {
                        case .success(_):
                            self?.postsArray.append(newPost)
                            Task {
                                for posts in self!.postsArray {
                                    guard let uuid = posts.uuid,
                                          let userID = UserAuthData.shared.uid else { return }
                                    try await posts.checkLike(postID: uuid, userID: userID)
                                    self?.collectionView.reloadData()
                                    self?.loadingIndicator.stopAnimating()
                                }
                            }
                        case .failure(let failure):
                            print(failure.localizedDescription)
                            self?.loadingIndicator.stopAnimating()
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}

//MARK: - setup search top bar
extension SearchViewController {
    func setupSearchTopBar() {
        searchTopBar.collectionView = collectionView
        searchTopBar.tableView = self.tableView
        searchTopBar.viewController = (nil, self)
    }
}
