//
//  CustomRegistrationTopBar.swift
//  NewProject
//
//  Created by Александр Федоткин on 29.12.2023.
//

import UIKit

class CustomRegistrationTopBar: UIView {
    
    var backButtonTapped: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    private func setupView() {
        let subview = loadViewFromXib()
        
        self.addSubview(subview)
    }
    
    private func loadViewFromXib() -> UIView {
        guard let bundle = Bundle.main.loadNibNamed("CustomRegistrationTopBar", owner: self)?.first as? UIView else { return UIView() }
        
        return bundle
    }
    
    @IBAction func backClicked(_ sender: Any) {
        
        backButtonTapped?()
    }
}
