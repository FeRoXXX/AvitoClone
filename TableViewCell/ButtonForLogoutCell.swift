//
//  ButtonForLogoutCell.swift
//  NewProject
//
//  Created by Александр Федоткин on 26.12.2023.
//

import UIKit

class ButtonForLogoutCell: UITableViewCell {
    @IBOutlet weak var customButton: CustomButtonEditPassword!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

