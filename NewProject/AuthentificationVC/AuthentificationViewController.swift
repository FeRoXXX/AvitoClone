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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var checkSignIn = true
    private var checkSignUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicator.hidesWhenStopped = true
        repeatPassword.isHidden = true
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Почта", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        repeatPassword.attributedPlaceholder = NSAttributedString(string: "Повторите пароль", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
    }

    //MARK: - Open google auth web model and get result
    @IBAction func logInWithGoogleClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        FireAuth.share.logInWithGoogle(presenting: self) {  result, error in
            if error == nil {
                if let email = Auth.auth().currentUser?.email as? String {
                    UserAuthData.shared.email = email
                }
                if let userId = Auth.auth().currentUser?.uid as? String {
                    UserAuthData.shared.uid = userId
                    FireAuth.share.checkUserDataExistence(uid: userId) { result, error in
                        if result?.data() == nil {
                            self.navigationController?.pushViewController(RegistrationViewController(), animated: true)
                            self.navigationController?.setNavigationBarHidden(true, animated: true)
                        } else {
                            self.navigationController?.pushViewController(MainTabBarViewController(), animated: true)
                            self.navigationController?.setNavigationBarHidden(true, animated: true)
                        }
                    }
                }
                self.activityIndicator.stopAnimating()
            } else {
                print(error?.localizedDescription as? String ?? "error")
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    //MARK: - Check input data + request to firebase, write if data correctly and push to vc
    @IBAction func signUpClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.repeatPassword.isHidden = false
        }
        
        if checkSignUp == true {
            guard let email = emailTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Введите почту для регистрации")
                self.activityIndicator.stopAnimating()
                return
            }
            guard let password = passwordTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Введите пароль")
                self.activityIndicator.stopAnimating()
                return
            }
            guard let repeatedPassword = repeatPassword.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Повторите пароль")
                self.activityIndicator.stopAnimating()
                return
            }
            
            guard password == repeatedPassword else {
                GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Пароли не совпадают")
                self.activityIndicator.stopAnimating()
                return
            }
            
            FireAuth.share.signUpWithEmail(email: email, password: password) {  result in
                switch result {
                case .success(_):
                    if let email = Auth.auth().currentUser?.email {
                        UserAuthData.shared.email = email
                    }
                    if let userId = Auth.auth().currentUser?.uid {
                        UserAuthData.shared.uid = userId
                    }
                    self.navigationController?.pushViewController(RegistrationViewController(), animated: true)
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                    self.activityIndicator.stopAnimating()
                case .failure(let error):
                    print(error.localizedDescription) //TODO: - alert
                    GlobalFunctions.alert(vc: self, title: "Ошибка регистрации", message: "Введены неверные данные")
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
        checkSignIn = false
        checkSignUp = true
    }
    
    //MARK: - Check input data + request to firebase and get result
    @IBAction func logInClicked(_ sender: Any) {
        self.activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.repeatPassword.text = ""
            self.repeatPassword.isHidden = true
        }
        
        if checkSignIn == true {
            guard let email = emailTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка входа", message: "Введите почту для регистрации")
                self.activityIndicator.stopAnimating()
                return
            }
            guard let password = passwordTextField.text else {
                GlobalFunctions.alert(vc: self, title: "Ошибка входа", message: "Введите пароль")
                self.activityIndicator.stopAnimating()
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
                                self.navigationController?.pushViewController(RegistrationViewController(), animated: true)
                                self.navigationController?.setNavigationBarHidden(true, animated: true)
                            } else {
                                FireGetData.shared.getDataFromUserBase()
                                self.navigationController?.pushViewController(MainTabBarViewController(), animated: true)
                                self.navigationController?.setNavigationBarHidden(true, animated: true)
                            }
                            self.activityIndicator.stopAnimating()
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription) //TODO: - alert
                    GlobalFunctions.alert(vc: self, title: "Ошибка входа", message: "Введены неверные данные")
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
        checkSignUp = false
        checkSignIn = true
    }
}
