//
//  CustomSearchAndSortField+Extensions.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit

//MARK: - setup TextField functions
extension CustomSearchAndSortField: UITextFieldDelegate {
    func setupTextField() {
        searchTextField.delegate = self
    }
    
    //Нажимаем textField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if searchTextField.rightImage != nil {
            if let tableView = self.tableView,
               let collectionView = self.collectionView {
                tableView.alpha = 0.0
                collectionView.isHidden = true
                tableView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    tableView.alpha = 100.0
                    collectionView.alpha = 0.0
                    self.searchTextField.rightView?.alpha = 100.0
                    //self.searchWidthConstrain.priority = UILayoutPriority(rawValue: 900)
                    self.toBackViewConstrain.priority = UILayoutPriority(1000)
                    self.searchConstraintWithCart.priority = UILayoutPriority(1)
                    self.layoutIfNeeded()
                } completion: { _ in
                    self.searchTextField.rightImage = nil
                    self.sortImage.image = nil
                    let button = UIButton(type: .custom)
                    button.setTitle("Отмена", for: .normal)
                    button.setTitleColor(.link, for: .normal)
                    button.frame = CGRect(x: CGFloat(20), y: CGFloat(20), width: CGFloat(25), height: CGFloat(25))
                    button.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
                    self.searchTextField.rightView = button
                    self.searchTextField.rightViewMode = .always
                }
            }
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        if searchTextField.rightImage == nil {
            if let tableView = self.tableView,
               let collectionView = self.collectionView {
                collectionView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    tableView.alpha = 0.0
                    collectionView.alpha = 100.0
                    self.searchTextField.rightView?.alpha = 0.0
                    self.searchWidthConstrain.priority = UILayoutPriority(rawValue: 10.0)
                    self.layoutIfNeeded()
                    self.toBackViewConstrain.priority = UILayoutPriority(100)
                    //self.searchWidthConstrain.priority = UILayoutPriority(250)
                    self.searchConstraintWithCart.priority = UILayoutPriority(1000)
                    self.layoutIfNeeded()
                } completion: { _ in
                    tableView.isHidden = true
                    self.searchTextField.text = ""
                    self.searchTextField.rightView = nil
                    self.searchTextField.rightImage = UIImage(systemName: "slider.horizontal.3")
                    self.searchTextField.resignFirstResponder()
                    self.sortImage.image = UIImage(systemName: "cart.fill")
                }
            }
        }
    }
    
    //Нажимаем на кнопку
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            print(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goToNewViewControllerFromSearchBar()
        return true
    }
    
}

//MARK: - Function for pushVC
extension CustomSearchAndSortField {
    func goToNewViewControllerFromSearchBar() {
        if let viewController = viewController.0 {
            if let navigationController = viewController.navigationController {
                let newVC = SearchViewController()
                if let text = searchTextField.text {
                    newVC.sortedText = text
                }
                navigationController.pushViewController(newVC, animated: true)
            }
        } else if let viewController = viewController.1 {
            if let navigationController = viewController.navigationController {
                let newVC = SearchViewController()
                if let text = searchTextField.text {
                    newVC.sortedText = text
                }
                navigationController.pushViewController(newVC, animated: true)
            }
        }
    }
}

