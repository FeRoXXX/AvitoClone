//
//  CustomButtonForRating.swift
//  NewProject
//
//  Created by Александр Федоткин on 11.12.2023.
//

import UIKit

class CustomButtonForRating: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    func setupButton()
    {
        Bundle.main.loadNibNamed("CustomButtonForRating", owner: self, options: nil)
    }
}
