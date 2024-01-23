//
//  PublicationCell.swift
//  NewProject
//
//  Created by Александр Федоткин on 10.12.2023.
//

import UIKit

class PublicationCell: UITableViewCell {
    
    @IBOutlet weak var publicationImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
