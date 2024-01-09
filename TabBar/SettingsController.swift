//
//  SettingsController.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.12.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class SettingsController: UIViewController {
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var customView: CustomProfileTopBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profileTableView.reloadData()
    }
}

//MARK: - Setup TableView
extension SettingsController : UITableViewDelegate, UITableViewDataSource {
    
    func setup() {
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.register(UINib(nibName: "ProfileInfoCell", bundle: nil), forCellReuseIdentifier: "ProfileInfoCell")
        profileTableView.register(UINib(nibName: "ButtonForLogoutCell", bundle: nil), forCellReuseIdentifier: "ButtonForLogoutCell")
        profileTableView.contentInset = UIEdgeInsets.zero
        profileTableView.tableHeaderView = nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .darkGray
        var cellStyle = cell.defaultContentConfiguration()
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileInfoCell") as? ProfileInfoCell {
                if let userName = UserAuthData.shared.name {
                    cell.firstSecondNameLabel.text = userName
                }
                
                if let image = UserAuthData.shared.profilePhoto {
                    cell.profileImageView.image = image
                }
                
                if let organization = UserAuthData.shared.organizationName {
                    cell.nameOfOrganisationLabel.text = organization
                }
                
                if let year = UserAuthData.shared.registrationYear {
                    cell.yearRegistrationLabel.text = "В приложении с \(year) года"
                }
                
                cell.toAddPhotoVC = { [weak self] in
                    self?.goToAddPhoto()
                }
                return cell
            }
        case 1:
            configureCell(&cellStyle, image: "doc.text.fill", text: "Заказы и заявки", secondaryText: "Пока пусто")
        case 2:
            configureCell(&cellStyle, text: "Управление профилем", secondaryText: "Доступные проверки и расширения")
        case 3:
            configureCell(&cellStyle, image: "creditcard.fill", text: "Кошелёк", secondaryText: "0 ₽")
        case 4:
            configureCell(&cellStyle, text: "Тариф", secondaryText: "Решения для бизнеса")
        case 5:
            configureCell(&cellStyle, text: "Спецпредложения", secondaryText: "Нет активных или запланированных")
        case 6:
            configureCell(&cellStyle, text: "Поиск работы", secondaryText: "У вас пока нет резюме")
        case 7:
            cellStyle.text = indexPath.row == 0 ? "Мои отзывы" : "Ждут оценки"
            cellStyle.secondaryText = indexPath.row == 0 ? "Нет отзывов" : "Нет продавцов"
        case 16:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonForLogoutCell") as? ButtonForLogoutCell {
                cell.customButton.buttonTextLabel.text = "Изменить пароль"
                cell.customButton.tapHandler = {
                    print("Correct password")
                }
                return cell
            }
        case 17:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonForLogoutCell") as? ButtonForLogoutCell {
                cell.customButton.buttonTextLabel.text = "Выйти"
                cell.customButton.tapHandler = {
                    do{
                        try Auth.auth().signOut()
                        if let rootViewController = self.view.window?.rootViewController {
                            rootViewController.dismiss(animated: true, completion: nil)
                            UserAuthData.shared.reset()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                return cell
            }
        default:
            break
        }
        
        cellStyle.secondaryTextProperties.color = .gray
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = cellStyle
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0...6, 8...13, 15...17:
            return 1
        case 7, 14:
            return 2
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .black
        return headerView
    }

    private func configureCell(_ cellStyle: inout UIListContentConfiguration, image: String? = nil, text: String, secondaryText: String) {
        cellStyle.image = image.flatMap({ UIImage(systemName:  $0)?.withTintColor(.gray, renderingMode: .alwaysOriginal) })
        cellStyle.text = text
        cellStyle.secondaryText = secondaryText
    }
    
    private func goToAddPhoto() {
        let profilePhoto = AddNewProfilePhotoViewController()
        profilePhoto.modalPresentationStyle = .fullScreen
        profilePhoto.modalTransitionStyle = .flipHorizontal
        self.present(profilePhoto, animated: true)
    }
    
}
