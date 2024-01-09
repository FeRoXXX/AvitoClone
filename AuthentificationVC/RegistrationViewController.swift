//
//  RegistrationViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 29.12.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class RegistrationViewController: UIViewController {
    @IBOutlet weak var topBar: CustomRegistrationTopBar!
    @IBOutlet weak var profileNameTextField: UITextField!
    @IBOutlet weak var tableViewButton: UIButton!
    @IBOutlet weak var organisationButton: UIButton!
    @IBOutlet weak var organizationNameTextField: UITextField!
    private var selectCity: String?
    
    lazy var actionClosure: (UIAction) -> Void = { [weak self] action in
        self?.selectCity = action.title
    }
    
    lazy var actionClosureForOrganization: (UIAction) -> Void = { [weak self] action in
        if action.title == "Организация" {
            UIView.animate(withDuration: 0.3) {
                self?.organizationNameTextField.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self?.organizationNameTextField.text = ""
                self?.organizationNameTextField.isHidden = true
            }
        }
    }
    
    //TODO: - API For cities
    let citiesArray = [
        "Москва",
        "Санкт-Петербург",
        "Новосибирск",
        "Екатеринбург",
        "Нижний Новгород",
        "Казань",
        "Челябинск",
        "Омск",
        "Самара",
        "Ростов-на-Дону",
    ]
    
    let organizationArray = [
        "Частное лицо",
        "Организация"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        organizationNameTextField.isHidden = true
        setupDropDownMenu()
        topBar.backButtonTapped = { [weak self] in
            self?.handleButtonTapped()
        }
        
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        guard let cityName = selectCity else {
            GlobalFunctions.alert(vc: self, title: "Ошибка введенных данных", message: "Введите город")
            return
        }
        guard let userName = profileNameTextField.text else {
            GlobalFunctions.alert(vc: self, title: "Ошибка введенных данных", message: "Введите имя пользователя")
            return
        }
        var organizationName = ""
        if organizationNameTextField.isHidden {
            organizationName = "Частное лицо"
        } else {
            guard let text = organizationNameTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка введенных данных", message: "Введите название организации")
                return
            }
            organizationName = text
        }
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let requestData = ["Name" : userName, "City" : cityName, "Organization" : organizationName, "RegistrationYear" : currentYear] as [String : Any]
        
        let db = Firestore.firestore()
        
        Task {
            do {
                try await FireLoadData.shared.loadRegisterData(db: db, requestData: requestData)
                FireGetData.shared.getDataFromUserBase()
                let mainScreen = MainTabBarViewController()
                mainScreen.modalPresentationStyle = .fullScreen
                mainScreen.modalTransitionStyle = .flipHorizontal
                self.present(mainScreen, animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Setup Drop Down menu for organization and cities
private extension RegistrationViewController {
    
    private func setupDropDownMenu() {
        var menuCities: [UIMenuElement] = []
        
        for city in citiesArray {
            menuCities.append(UIAction(title: city, state: .on, handler: actionClosure))
        }
        
        tableViewButton.menu = UIMenu(options: .displayInline, children: menuCities)
        
        tableViewButton.showsMenuAsPrimaryAction = true
        tableViewButton.changesSelectionAsPrimaryAction = true
        
        var menuOrganizations: [UIMenuElement] = []
        
        for organization in organizationArray {
            menuOrganizations.append(UIAction(title: organization, state: .on, handler: actionClosureForOrganization))
        }
        
        organisationButton.menu = UIMenu(options: .displayInline, children: menuOrganizations)
        
        organisationButton.showsMenuAsPrimaryAction = true
        organisationButton.changesSelectionAsPrimaryAction = true
    }
}
