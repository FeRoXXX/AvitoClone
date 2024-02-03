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
    
    var posts : UserPosts?
    weak var vc : UIViewController?
    
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
        //postsArray.removeAll()
        setupPublication()
    }
    
    @objc func refreshData() {
        loadData()
    }
    
    deinit {
        print("Scroll and collection was deinited")
    }
}
