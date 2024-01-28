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
    
    var handleTapped: (() -> (Void))?
    var image: UIImage? = UIImage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        publicationImage.layer.cornerRadius = 5
        likeImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addLike))
        likeImage.addGestureRecognizer(tapGesture)
    }
    
    func setupImage() {
        let resizedImage = resizeImageToFullHD(image!)
        publicationImage.image = resizedImage
    }
    
    func resizeImageToFullHD(_ image: UIImage) -> UIImage? {
        let targetSize = CGSize(width: 640, height: 480)

        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    @objc func addLike() {
        handleTapped?()
    }

}
