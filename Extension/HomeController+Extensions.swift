//
//  HomeController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit

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
extension HomeController {
    
    func getAllPosts() {
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
