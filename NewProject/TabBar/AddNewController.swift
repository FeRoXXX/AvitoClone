//
//  AddNewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit

class AddNewController: UIViewController {
    @IBOutlet weak var noPublication: NoPublicationView!
    @IBOutlet weak var myPublicationView: ScrollAndCollectionViewForAddNewController!
    @IBOutlet weak var topBar: MyPostsTopBar!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.hidesWhenStopped = true
        self.checkAvailabilityPublication()
        self.setupPublication()
        
        noPublication.addPublication = { [weak self] in
            self?.handleButtonTapped()
        }
        topBar.newPublicationClicked = { [weak self] in
            self?.handleButtonTapped()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myPublicationView.vc = self
    }
}
