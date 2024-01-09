//
//  MainTabBarViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.12.2023.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    let customTabBar = CustomTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeController = HomeController()
        let addNewController = AddNewController()
        let settingsController = SettingsController()
        
        customTabBar.delegate = self
        view.addSubview(customTabBar)
        self.setValue(customTabBar, forKey: "tabBar")
        
        homeController.title = "Публикации"
        homeController.tabBarItem.image = UIImage(systemName: "cart")
        addNewController.title = "Добавить"
        addNewController.tabBarItem.image = UIImage(systemName: "plus")
        settingsController.title = "Настройки"
        settingsController.tabBarItem.image = UIImage(systemName: "gearshape.2")
        self.modalTransitionStyle = .flipHorizontal
        
        self.setViewControllers([homeController, addNewController, settingsController], animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
                customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
                customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
                customTabBar.topAnchor.constraint(equalTo: tabBar.topAnchor),
                customTabBar.heightAnchor.constraint(equalTo: tabBar.heightAnchor)
            ])
            customTabBar.updateCurveForTappedIndex()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let tabbar = tabBar as? CustomTabBar {
            tabbar.updateCurveForTappedIndex()
        }
    }

}
