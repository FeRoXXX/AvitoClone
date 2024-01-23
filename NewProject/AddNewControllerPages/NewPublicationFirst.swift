//
//  NewPublicationFirst.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.01.2024.
//

import UIKit

class NewPublicationFirst: UIViewController {
    @IBOutlet weak var topBar: UniversalTopBar!
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        // Do any additional setup after loading the view.
        topBar.topBarText.text = "Выберите категорию"
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
        topBar.firstButton.isHidden = true
        topBar.secondButton.isHidden = true
    }

    private func handleButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
    }
}

//MARK: - setup table view
extension NewPublicationFirst: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var cellStyle = cell.defaultContentConfiguration()
        if indexPath.row == 0 {
            cellStyle.text = "Товары"
            cellStyle.image = UIImage(systemName: "camera")
        }
        if indexPath.row == 1 {
            cellStyle.text = "Работа"
            cellStyle.image = UIImage(systemName: "bag")
        }
        cell.tintColor = .black
        cell.backgroundColor = .darkGray
        cell.contentConfiguration = cellStyle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.hidesBottomBarWhenPushed = true
            let productsScreen = ProductsViewController()
            if let navigationController = self.navigationController {
                navigationController.pushViewController(productsScreen, animated: true)
            }
        }
        if indexPath.row == 1 {
            print("Work")
        }
    }
    
}
