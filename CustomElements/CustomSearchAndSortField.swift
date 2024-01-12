//
//  CustomSearchAndSortField.swift
//  NewProject
//
//  Created by Александр Федоткин on 27.12.2023.
//

import UIKit

class CustomSearchAndSortField: UIView {
    
    @IBOutlet weak var searchWidthConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var searchWidthConstrainHigh: NSLayoutConstraint!
    
    @IBOutlet weak var searchTextField: CustomSearchString!
    @IBOutlet weak var sortImage: UIImageView!
    var collectionView : UICollectionView?
    var tableView : UITableView?
    var viewController : (HomeController?, SearchViewController?)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        setupTextField()
        if let tableView = self.tableView {
            tableView.isHidden = true
        }
    }
    
    private func configureView() {
        let subview = loadViewFromXib()
        
        self.addSubview(subview)
    }
    private func loadViewFromXib() -> UIView {
        guard let view = Bundle.main.loadNibNamed("CustomSearchAndSortField", owner: self)?.first as? UIView else { return UIView() }
        
        return view
    }
}

