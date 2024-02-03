//
//  AddNewController+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 23.01.2024.
//

import UIKit

//MARK: - supporting function
extension AddNewController {
    
    func checkAvailabilityPublication() {
        if (myPublicationView.getNumOfSections() != 0) {
            noPublication.isHidden = true
            myPublicationView.isHidden = false
            topBar.addNewButton.isHidden = false
        } else {
            myPublicationView.isHidden = true
            noPublication.isHidden = false
            topBar.addNewButton.isHidden = true
        }
    }
    
    func handleButtonTapped() {
        let addNew = NewPublicationFirst()
        hidesBottomBarWhenPushed = true
        if let navigationController = navigationController {
            navigationController.pushViewController(addNew, animated: true)
        }
        hidesBottomBarWhenPushed = false
    }
}
