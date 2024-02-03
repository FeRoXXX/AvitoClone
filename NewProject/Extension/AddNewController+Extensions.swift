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
        if (self.myPublicationView.getNumOfSections() != 0) {
            self.noPublication.isHidden = true
            self.myPublicationView.isHidden = false
            self.topBar.addNewButton.isHidden = false
        } else {
            self.myPublicationView.isHidden = true
            self.noPublication.isHidden = false
            self.topBar.addNewButton.isHidden = true
        }
    }
    
    func handleButtonTapped() {
        let addNew = NewPublicationFirst()
        self.hidesBottomBarWhenPushed = true
        if let navigationController = self.navigationController {
            navigationController.pushViewController(addNew, animated: true)
        }
        self.hidesBottomBarWhenPushed = false
    }
}
