//
//  ProfileInfoCell.swift
//  NewProject
//
//  Created by Александр Федоткин on 25.12.2023.
//

import UIKit

class ProfileInfoCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstSecondNameLabel: UILabel!
    @IBOutlet weak var yearRegistrationLabel: UILabel!
    @IBOutlet weak var nameOfOrganisationLabel: UILabel!
    @IBOutlet weak var profileNumberLabel: UILabel!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    var toAddPhotoVC: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profileImageView.image = UIImage(systemName: "plus")
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToAddProfilePhoto))
        profileImageView.addGestureRecognizer(gestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc func goToAddProfilePhoto() {
        toAddPhotoVC?()
        
    }
    
}
