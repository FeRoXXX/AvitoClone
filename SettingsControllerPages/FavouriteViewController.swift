//
//  FavouritesViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 22.01.2024.
//

import UIKit

class FavouriteViewController: UIViewController {
    @IBOutlet weak var topBar: UniversalTopBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var postsArray = [ReceivedAllPosts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopBar()
        setupCollection()
        getAllPosts()
        view.backgroundColor = .darkGray
    }

}

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
        guard postsArray.count > 0 else { return cell }
        
        cell.publicationName.text = postsArray[indexPath.row].name
        cell.publicationImage.image = postsArray[indexPath.row].image
        cell.publicationPrice.text = postsArray[indexPath.row].price
        cell.publicationTime.text = postsArray[indexPath.row].date
        cell.sellerAdress.text = postsArray[indexPath.row].address
        cell.handleTapped = { [weak self] in
            self?.likeButtonTapped(currentIndex: indexPath.row, indexPath: indexPath)
        }
        cell.likeImage.image = UIImage(systemName: "heart.fill")
        
        return cell
    }
    
    func likeButtonTapped(currentIndex: Int, indexPath: IndexPath) {
        guard let currentPostUUID = postsArray[currentIndex].uuid,
              let currentUserUUID = UserAuthData.shared.uid else { return }
        Task {
            do {
                try await postsArray[currentIndex].addLikeToPublication(postID: currentPostUUID, userID: currentUserUUID)
                postsArray.remove(at: currentIndex)
                UIView.animate(withDuration: 0.3) {
                    self.collectionView.reloadData()
                }
            } catch {
                print("error")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let spacingBetweenCells: CGFloat = 10.0
        let cellWidth = (collectionViewWidth - spacingBetweenCells) / 2.0
        return CGSize(width: cellWidth, height: 260)
    }
}

//MARK: - get data from base
extension FavouriteViewController {
    func getAllPosts() {
        Task(priority: .high) {
            do {
                let posts = try await ReceivedAllPosts.init()
                guard posts.data.count > 0 else { return }
                let likedPostsID = try await posts.checkLikedPostsForFavourite()
                for postIndex in (0...posts.data.count - 1) {
                    let newPost = ReceivedAllPosts(postData: posts.data)
                    newPost.dictionaryToVariables(index: postIndex) { [weak self] result in
                        switch result {
                        case .success(_):
                            if likedPostsID.contains(newPost.uuid!.uuidString) {
                                self?.postsArray.append(newPost)
                                Task {
                                    for posts in self!.postsArray {
                                        guard let uuid = posts.uuid,
                                              let userID = UserAuthData.shared.uid else { return }
                                        try await posts.checkLike(postID: uuid, userID: userID)
                                        self?.collectionView.reloadData()
                                    }
                                }
                            }
                            
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
