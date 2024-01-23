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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profileTableView.reloadData()
    }
}
