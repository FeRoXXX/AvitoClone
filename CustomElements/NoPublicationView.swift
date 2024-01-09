//
//  NoPublicationView.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit

class NoPublicationView: UIView {
    
    var addPublication: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadView()
    }
    
    private func loadView() {
        let subview = loadFromNib()
        
        self.addSubview(subview)
    }
    
    private func loadFromNib() -> UIView {
        guard let bundle = Bundle.main.loadNibNamed("NoPublicationView", owner: self)?.first as? UIView else { return UIView() }
        
        return bundle
    }
    
    @IBAction func addPublicationClicked(_ sender: Any) {
        addPublication?()
    }
}
