//
//  CustomViewButtonForRating.swift
//  NewProject
//
//  Created by Александр Федоткин on 25.12.2023.
//

import UIKit

class CustomViewButtonForRating: UIView {
    
    var tapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let subview = loadViewFromXib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        self.addSubview(subview)
    }
    private func loadViewFromXib() -> UIView {
        guard let view = Bundle.main.loadNibNamed("CustomViewButtonForRating", owner: self)?.first as? UIView else { return UIView() }
        
        return view
    }
    
    @objc private func handleTap() {
        tapHandler?()
    }
}
