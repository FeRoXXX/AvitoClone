//
//  MyPostsTopBar.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit

class MyPostsTopBar: UIView {
    @IBOutlet weak var addNewButton: UIButton!
    
    var newPublicationClicked: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        setupView()
        
    }
    
    private func setupView() {
        let subview = loadFromXib()
        
        self.addSubview(subview)
    }
    
    private func loadFromXib() -> UIView {
        guard let bundle = Bundle.main.loadNibNamed("MyPostsTopBar", owner: self)?.first as? UIView else { return UIView() }
        
        return bundle
    }
    
    
    @IBAction func addNewButtonClicked(_ sender: Any) {
        newPublicationClicked?()
    }
    
}
