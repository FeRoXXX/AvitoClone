//
//  AuthentificationViewController.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class AuthentificationViewController: UIViewController {
    
    @IBOutlet weak var logInWithGoogle: GIDSignInButton!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var checkSignIn = true
    private var checkSignUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        repeatPassword.isHidden = true
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Почта", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        repeatPassword.attributedPlaceholder = NSAttributedString(string: "Повторите пароль", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
    }

    @IBAction func logInWithGoogleClicked(_ sender: Any) {
        FireAuth.share.logInWithGoogle(presenting: self) { result, error in
            if error == nil {
                if let email = Auth.auth().currentUser?.email as? String {
                    UserAuthData.shared.email = email
                }
                if let userId = Auth.auth().currentUser?.uid as? String {
                    UserAuthData.shared.uid = userId
                    FireAuth.share.checkUserDataExistence(uid: userId) { result, error in
                        if result?.data() == nil {
                            let registrationScreen = RegistrationViewController()
                            registrationScreen.modalPresentationStyle = .fullScreen
                            registrationScreen.modalTransitionStyle = .flipHorizontal
                            self.present(registrationScreen, animated: true)
                        } else {
                            FireGetData.shared.getDataFromUserBase()
                            let mainScreen = MainTabBarViewController()
                            mainScreen.modalPresentationStyle = .fullScreen
                            mainScreen.modalTransitionStyle = .flipHorizontal
                            self.present(mainScreen, animated: true)
                        }
                    }
                }
            } else {
                print(error?.localizedDescription as? String ?? "error")
            }
        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.repeatPassword.isHidden = false
        }
        
        if checkSignUp == true {
            guard let email = emailTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Введите почту для регистрации")
                return
            }
            guard let password = passwordTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Введите пароль")
                return
            }
            guard let repeatedPassword = repeatPassword.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Повторите пароль")
                return
            }
            
            guard password == repeatedPassword else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Пароли не совпадают")
                return
            }
            
            FireAuth.share.signUpWithEmail(email: email, password: password) { result in
                switch result {
                case .success(_):
                    if let email = Auth.auth().currentUser?.email {
                        UserAuthData.shared.email = email
                    }
                    if let userId = Auth.auth().currentUser?.uid {
                        UserAuthData.shared.uid = userId
                    }
                    
                    let registrationScreen = RegistrationViewController()
                    registrationScreen.modalPresentationStyle = .fullScreen
                    registrationScreen.modalTransitionStyle = .flipHorizontal
                    self.present(registrationScreen, animated: true)
                case .failure(let error):
                    print(error.localizedDescription) //TODO: - alert
                    GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Введены неверные данные")
                }
            }
        }
        
        checkSignIn = false
        checkSignUp = true
    }
    
    @IBAction func logInClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.repeatPassword.text = ""
            self.repeatPassword.isHidden = true
        }
        
        if checkSignIn == true {
            guard let email = emailTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка входа", message: "Введите почту для регистрации")
                return
            }
            guard let password = passwordTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка входа", message: "Введите пароль")
                return
            }
            FireAuth.share.logInWithEmail(email: email, password: password) { result in
                switch result {
                case .success(_):
                    if let email = Auth.auth().currentUser?.email {
                        UserAuthData.shared.email = email
                    }
                    if let userId = Auth.auth().currentUser?.uid as? String {
                        UserAuthData.shared.uid = userId
                        FireAuth.share.checkUserDataExistence(uid: userId) { result, error in
                            if result?.data() == nil {
                                let registrationScreen = RegistrationViewController()
                                registrationScreen.modalPresentationStyle = .fullScreen
                                registrationScreen.modalTransitionStyle = .flipHorizontal
                                self.present(registrationScreen, animated: true)
                            } else {
                                FireGetData.shared.getDataFromUserBase()
                                let mainScreen = MainTabBarViewController()
                                mainScreen.modalPresentationStyle = .fullScreen
                                mainScreen.modalTransitionStyle = .flipHorizontal
                                self.present(mainScreen, animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription) //TODO: - alert
                    GlobalFunctions.alert(vc: self, title: "Ошибка входа", message: "Введены неверные данные")
                }
            }
        }
        checkSignUp = false
        checkSignIn = true
    }
    
    
    
}

