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
    @IBOutlet weak var toBackViewConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var searchConstraintWithCart: NSLayoutConstraint!
    
    weak var collectionView : UICollectionView?
    weak var tableView : UITableView?
    weak var viewController : UIViewController?
    
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
    deinit {
        print("Search top bar was deinited")
    }
}

