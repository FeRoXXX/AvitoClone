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
            
            FireAuth.share.checkUserDataExistence(uid: uid) { [weak self] result, error in
                guard let self = self else {
                    return
                }
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
        viewControllers = [navigationController]
    }
    
    private func setAuthenticationViewControllerRoot() {
        let navigationController = AuthentificationViewController()
        viewControllers = [navigationController]
    }
}
