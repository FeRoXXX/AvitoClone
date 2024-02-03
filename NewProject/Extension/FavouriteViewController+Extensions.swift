//
//  FavouriteViewController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 23.01.2024.
//

import UIKit

//MARK: - setup collection view
extension FavouriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .darkGray
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionViewCell")
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
            self?.likeButtonTapped(currentIndex: indexPath.row, indexPath: indexPath)
        }
        cell.likeImage.image = UIImage(systemName: "heart.fill")
        
        return cell
    }
    
    func likeButtonTapped(currentIndex: Int, indexPath: IndexPath) {
        guard let posts = posts else { return }
        Task {
            do {
                try await posts.addLikeToPublication(index: currentIndex)
                posts.postsArray.remove(at: currentIndex)
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.reloadData()
                }
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacingBetweenCells: CGFloat = 10.0
        let cellWidth = (collectionViewWidth - spacingBetweenCells) / 2.0
        return CGSize(width: cellWidth, height: 260)
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

//MARK: - get data from base
extension FavouriteViewController {
    func getAllPosts() {
        self.loadingIndicator.startAnimating()
        Task(priority: .high) {
            posts = try await ReceivedAllPosts()
            self.posts?.postsArray = posts!.postsArray.filter{$0.checkedLikeImage == true}
            collectionView.reloadData()
            self.loadingIndicator.stopAnimating()
        }
    }
}

//MARK: - setup topBar
extension FavouriteViewController {
    
    func setupTopBar() {
        topBar.topBarText.text = "Избранное"
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
    }
    
    func handleButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}
