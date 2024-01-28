//
//  SettingsController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.12.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class SettingsController: UIViewController {
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var customView: CustomProfileTopBar!
    
    var firstOpen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setup()
        firstOpen = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if firstOpen {
            firstOpen = false
        } else {
            profileTableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let cell = profileTableView.visibleCells[0] as? ProfileInfoCell {
            cell.profileImageView.image = UIImage(systemName: "heart")
        }
    }
    deinit {
        print("settings controller deinited")
    }
}
