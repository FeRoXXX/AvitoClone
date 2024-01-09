//
//  HomeController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.12.2023.
//

import UIKit

class HomeController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    static let shared = HomeController()
    var postsArray = [ReceivedAllPosts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setup()
        getAllPosts()
        
    }
}

//MARK: - Setup tableView

extension HomeController : UICollectionViewDelegate, UICollectionViewDataSource {

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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard postsArray.count > 0 else { return 0 }
        return postsArray.count
    }
}

//MARK: - Get all posts from firebase
private extension HomeController {
    
    private func getAllPosts() {
        Task(priority: .high) {
            do {
                let posts = try await ReceivedAllPosts.init()
                
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
