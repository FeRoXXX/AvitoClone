//
//  ScrollAndCollectionViewForAddNewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit

class ScrollAndCollectionViewForAddNewController: UIView {
    @IBOutlet weak var myPublicationCollectionView: UICollectionView!
    
    var postsArray = [UserPosts]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadView()
        setup()
    }
    
    private func loadView() {
        let subview = loadFromNib()
        
        self.addSubview(subview)
    }
    
    private func loadFromNib() -> UIView {
        guard let bundle = Bundle.main.loadNibNamed("ScrollAndCollectionViewForAddNewController", owner: self)?.first as? UIView else { return UIView() }
        
        return bundle
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
}

//MARK: - get numbers of sections
extension ScrollAndCollectionViewForAddNewController {
    func getNumOfSections() -> Int {
        guard postsArray.count > 0 else { return 0}
        return postsArray.count
    }
}
