//
//  AddNewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit

class AddNewController: UIViewController {
    @IBOutlet weak var noPublication: NoPublicationView!
    @IBOutlet weak var myPublicationView: ScrollAndCollectionViewForAddNewController!
    @IBOutlet weak var topBar: MyPostsTopBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkAvailabilityPublication()
        self.setupPublication()
        
        noPublication.addPublication = { [weak self] in
            self?.handleButtonTapped()
        }
        topBar.newPublicationClicked = { [weak self] in
            self?.handleButtonTapped()
        }
        
    }
}

//MARK: - supporting function
private extension AddNewController {
    
    private func checkAvailabilityPublication() {
        if (self.myPublicationView.getNumOfSections() != 0) {
            self.noPublication.isHidden = true
            self.myPublicationView.isHidden = false
        } else {
            self.myPublicationView.isHidden = true
            self.noPublication.isHidden = false
        }
    }
    
    private func handleButtonTapped() {
        let addNew = NewPublicationFirst()
        addNew.modalPresentationStyle = .fullScreen
        addNew.modalTransitionStyle = .flipHorizontal
        self.present(addNew, animated: true)
    }
}

//MARK: - search publication and setup collectionView
private extension AddNewController {
    
    private func setupPublication() {
        if let userId = UserAuthData.shared.uid {
            Task(priority: .high) {
                do {
                    let posts = try await UserPosts.init(userID: userId)
                    guard posts.data.count > 0 else { return }
                    for postIndex in (0...posts.data.count - 1) {
                        let newPost = UserPosts(postData: posts.data)
                        newPost.dictionaryToVariables(index: postIndex) { result in
                            switch result {
                            case .success(_):
                                self.myPublicationView.postsArray.append(newPost)
                                self.myPublicationView.myPublicationCollectionView.reloadData()
                                
                                self.checkAvailabilityPublication()
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
}