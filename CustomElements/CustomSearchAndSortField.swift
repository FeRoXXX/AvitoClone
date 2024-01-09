//
//  CustomSearchAndSortField.swift
//  NewProject
//
//  Created by Александр Федоткин on 27.12.2023.
//

import UIKit

class CustomSearchAndSortField: UIView {
    
    @IBOutlet weak var searchTextField: CustomSearchString!
    @IBOutlet weak var sortImage: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
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

