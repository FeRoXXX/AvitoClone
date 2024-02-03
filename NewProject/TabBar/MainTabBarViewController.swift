//
//  MainTabBarViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.12.2023.
//

import UIKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    var customTabBar : CustomTabBar? = CustomTabBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var homeController : UINavigationController? = UINavigationController(rootViewController: HomeController())
        homeController!.setNavigationBarHidden(true, animated: true)
        var addNewController : UINavigationController? = UINavigationController(rootViewController: AddNewController())
        addNewController!.setNavigationBarHidden(true, animated: true)
        var settingsController : SettingsController? = SettingsController()
        
        customTabBar!.delegate = self
        view.addSubview(customTabBar!)
        setValue(customTabBar!, forKey: "tabBar")
        
        homeController!.title = "Публикации"
        homeController!.tabBarItem.image = UIImage(systemName: "cart")
        addNewController!.title = "Добавить"
        addNewController!.tabBarItem.image = UIImage(systemName: "plus")
        settingsController!.title = "Настройки"
        settingsController!.tabBarItem.image = UIImage(systemName: "gearshape.2")
        modalTransitionStyle = .flipHorizontal
        
        setViewControllers([homeController!, addNewController!, settingsController!], animated: true)
        homeController = nil
        addNewController = nil
        settingsController = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
                customTabBar!.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
                customTabBar!.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
                customTabBar!.topAnchor.constraint(equalTo: tabBar.topAnchor),
                customTabBar!.heightAnchor.constraint(equalTo: tabBar.heightAnchor)
            ])
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let tabbar = tabBar as? CustomTabBar {
            tabbar.updateCurveForTappedIndex()
        }
    }

}
