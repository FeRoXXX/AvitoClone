//
//  GlobalFunctions.swift
//  NewProject
//
//  Created by Александр Федоткин on 09.01.2024.
//

import UIKit

class GlobalFunctions {
    
    //TODO: - Make custom alert
    static func alert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Хорошо", style: UIAlertAction.Style.cancel)
        alert.addAction(okButton)
        vc.present(alert, animated: true)
    }
    
    static func quit() {
        HomeController.shared.postsArray.removeAll()
    }
}
