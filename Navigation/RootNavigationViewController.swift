//
//  RootNavigationViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 10.01.2024.
//

import UIKit
import FirebaseAuth

class RootNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uid = Auth.auth().currentUser?.uid {
            setMainTabBarRoot()
            UserAuthData.shared.uid = uid
            if let email = Auth.auth().currentUser?.email {
                UserAuthData.shared.email = email
            }
            
            FireAuth.share.checkUserDataExistence(uid: uid) { result, error in
                if result?.data() == nil {
                    self.setAuthenticationViewControllerRoot()
                } else {
                    FireGetData.shared.getDataFromUserBase()
                }
            }
        } else {
            setAuthenticationViewControllerRoot()
        }

    }

    private func setMainTabBarRoot() {
        let navigationController = MainTabBarViewController()
        self.viewControllers = [navigationController]
    }
    
    private func setAuthenticationViewControllerRoot() {
        let navigationController = AuthentificationViewController()
        self.viewControllers = [navigationController]
    }
}
