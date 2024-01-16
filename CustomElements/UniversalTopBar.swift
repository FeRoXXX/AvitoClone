//
//  UniversalTopBar.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.01.2024.
//

import UIKit

class UniversalTopBar: UIView {
    
    @IBOutlet weak var topBarText: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    var backButtonTapped: (() -> Void)?
    var firstButtonTapped: (() -> Void)?
    var secondButtonTapped: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
    }
    
    private func setupView() {
        let subview = loadFromXib()
        
        self.addSubview(subview)
    }
    
    private func loadFromXib() -> UIView {
        guard let bundle = Bundle.main.loadNibNamed("UniversalTopBar", owner: self)?.first as? UIView else { return UIView()}
        
        return bundle
    }
    
    @IBAction func backClicked(_ sender: Any) {
        backButtonTapped?()
    }
    
    @IBAction func firstButtonClicked(_ sender: Any) {
        firstButtonTapped?()
    }
    @IBAction func secondButtonClicked(_ sender: Any) {
        secondButtonTapped?()
    }
    
}
