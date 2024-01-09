//
//  CustomProfileTopBar.swift
//  NewProject
//
//  Created by Александр Федоткин on 10.12.2023.
//

import UIKit

class CustomProfileTopBar : UIView {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var settingsMenu: UIButton!
    @IBOutlet var view: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureView()
    }

    private func configureView() {
        let subview = self.loadViewFromXib()
        subview.frame = self.bounds
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        subview.layer.shadowColor = UIColor.black.cgColor
        subview.layer.shadowOpacity = 0.5
        subview.layer.shadowOffset = CGSize(width: 0, height: 2)
        subview.layer.shadowRadius = 2
        
        self.addSubview(subview)
    }

    private func loadViewFromXib() -> UIView {
        guard let view = Bundle.main.loadNibNamed("CustomProfileTopBar", owner: self)?.first as? UIView else { return UIView() }
        
        return view
    }
}

//MARK: - Setup Menu

private extension CustomProfileTopBar {
    
    func setup() {
        
    }
}
