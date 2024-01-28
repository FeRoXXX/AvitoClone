//
//  ScrollAndCollectionViewForAddNewController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 23.01.2024.
//

import UIKit

//MARK: - get publication from firebase
extension ScrollAndCollectionViewForAddNewController {
    
    func setupPublication() {
        if let userId = UserAuthData.shared.uid {
            Task(priority: .high) {
                do {
                    let posts = try await UserPosts.init(userID: userId)
                    guard posts.data.count > 0 else { return }
                    for postIndex in (0...posts.data.count - 1) {
                        let newPost = UserPosts(postData: posts.data)
                        newPost.dictionaryToVariables(index: postIndex) { [weak self] result in
                            switch result {
                            case .success(_):
                                self?.postsArray.append(newPost)
                                if postIndex == posts.data.count - 1 {
                                    self?.myPublicationCollectionView.reloadData()
                                }
                            case .failure(let failure):
                                print(failure.localizedDescription)
                            }
                        }
                    }
                    self.refreshControl.endRefreshing()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}
//MARK: - setup collectionView
extension ScrollAndCollectionViewForAddNewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setup() {
        myPublicationCollectionView.delegate = self
        myPublicationCollectionView.dataSource = self
        myPublicationCollectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard postsArray.count > 0 else { return 0}
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        
        guard postsArray.count > 0 else { return cell }
        
        cell.publicationName.text = postsArray[indexPath.row].name
        cell.image = postsArray[indexPath.row].image
        cell.publicationPrice.text = postsArray[indexPath.row].price
        cell.publicationTime.text = postsArray[indexPath.row].date
        cell.sellerAdress.text = postsArray[indexPath.row].address
        cell.likeImage.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacingBetweenCells: CGFloat = 10.0
        let cellWidth = (collectionViewWidth - spacingBetweenCells) / 2.0
        return CGSize(width: cellWidth, height: 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = self.vc else { return }
        let detailsViewController = UniversalCellDetailsViewController()
        detailsViewController.scrollAndCollectionVC = self
        detailsViewController.uuid = postsArray[indexPath.row].uuid
        vc.hidesBottomBarWhenPushed = true
        detailsViewController.buttonFlag = true
        
        
        if let navigationController = vc.navigationController {
            navigationController.pushViewController(detailsViewController, animated: true)
        }
        vc.hidesBottomBarWhenPushed = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? HomeCollectionViewCell
        cell?.publicationImage.image = UIImage(systemName: "heart")
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? HomeCollectionViewCell
        cell?.setupImage()
    }
}

//MARK: - get numbers of sections
extension ScrollAndCollectionViewForAddNewController {
    func getNumOfSections() -> Int {
        guard postsArray.count > 0 else { return 0}
        return postsArray.count
    }
}

