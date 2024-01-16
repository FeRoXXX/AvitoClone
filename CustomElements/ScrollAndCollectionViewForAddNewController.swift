//
//  ScrollAndCollectionViewForAddNewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit

class ScrollAndCollectionViewForAddNewController: UIView {
    @IBOutlet weak var myPublicationCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    let refreshControl = UIRefreshControl()
    
    var postsArray = [UserPosts]()
    var vc : UIViewController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadView()
        setup()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        scrollView.refreshControl = refreshControl
    }
    
    private func loadView() {
        let subview = loadFromNib()
        
        self.addSubview(subview)
    }
    
    private func loadFromNib() -> UIView {
        guard let bundle = Bundle.main.loadNibNamed("ScrollAndCollectionViewForAddNewController", owner: self)?.first as? UIView else { return UIView() }
        
        return bundle
    }
    
    func loadData() {
        postsArray.removeAll()
        setupPublication()
    }
    @objc func refreshData() {
        loadData()
    }
    
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
                                self.postsArray.append(newPost)
                                self.myPublicationCollectionView.reloadData()
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
    private func setup() {
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
        cell.publicationImage.image = postsArray[indexPath.row].image
        cell.publicationPrice.text = postsArray[indexPath.row].price
        
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
}

//MARK: - get numbers of sections
extension ScrollAndCollectionViewForAddNewController {
    func getNumOfSections() -> Int {
        guard postsArray.count > 0 else { return 0}
        return postsArray.count
    }
}
