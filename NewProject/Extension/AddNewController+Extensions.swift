//
//  AddNewController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 23.01.2024.
//

import UIKit

//MARK: - supporting function
extension AddNewController {
    
    func checkAvailabilityPublication() {
        if (self.myPublicationView.getNumOfSections() != 0) {
            self.noPublication.isHidden = true
            self.myPublicationView.isHidden = false
            self.topBar.addNewButton.isHidden = false
        } else {
            self.myPublicationView.isHidden = true
            self.noPublication.isHidden = false
            self.topBar.addNewButton.isHidden = true
        }
    }
    
    func handleButtonTapped() {
        let addNew = NewPublicationFirst()
        self.hidesBottomBarWhenPushed = true
        if let navigationController = self.navigationController {
            navigationController.pushViewController(addNew, animated: true)
        }
        self.hidesBottomBarWhenPushed = false
    }
}

//MARK: - search publication and setup collectionView
extension AddNewController {
    
    func setupPublication() {
        self.loadingIndicator.startAnimating()
        if let userId = UserAuthData.shared.uid {
            Task(priority: .high) {
                do {
                    let posts = try await UserPosts.init(userID: userId)
                    guard posts.data.count > 0 else {
                        self.loadingIndicator.stopAnimating()
                        return
                    }
                    for postIndex in (0...posts.data.count - 1) {
                        let newPost = UserPosts(postData: posts.data)
                        newPost.dictionaryToVariables(index: postIndex) { [weak self]result in
                            switch result {
                            case .success(_):
                                self?.myPublicationView.postsArray.append(newPost)
                                self?.myPublicationView.myPublicationCollectionView.reloadData()
                                
                                self?.checkAvailabilityPublication()
                                self?.loadingIndicator.stopAnimating()
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
}
