//
//  HomeCollectionViewCell.swift
//  NewProject
//
//  Created by Александр Федоткин on 26.12.2023.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var publicationImage: UIImageView!
    @IBOutlet weak var publicationName: UILabel!
    @IBOutlet weak var publicationPrice: UILabel!
    @IBOutlet weak var sellerAdress: UILabel!
    @IBOutlet weak var publicationTime: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        publicationImage.layer.cornerRadius = 5
    }

}
