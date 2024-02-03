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
        guard let userID = UserAuthData.shared.uid else { return }
        Task {
            do {
                posts = try await UserPosts(userID: userID)
                self.myPublicationCollectionView.reloadData()
            } catch {
                print("Error")
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
        guard let vc = self.vc,
            let posts = posts else { return }
        let detailsViewController = UniversalCellDetailsViewController()
        detailsViewController.scrollAndCollectionVC = self
        detailsViewController.uuid = posts.postsArray[indexPath.row].uuid
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
        Task {
            try await cell?.setupImage()
        }
    }
}

//MARK: - get numbers of sections
extension ScrollAndCollectionViewForAddNewController {
    func getNumOfSections() -> Int {
        guard let posts = posts,
              posts.postsArray.count > 0 else { return 0 }
        return posts.postsArray.count
    }
}

