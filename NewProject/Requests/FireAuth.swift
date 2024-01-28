//
//  FireAuth.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseFirestore

struct FireAuth {
    static let share = FireAuth()
    private var emailLink: String?
    
    func logInWithGoogle(presenting: UIViewController, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [unowned presenting] result, error in
            
          guard error == nil else {
              completion(nil, error)
            return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    completion(nil, error)
                    return
                }
                completion(result, nil)
            }
        }
    }
    
    func logInWithEmail(email: String, password: String, completion: @escaping(Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
        }
    }
    
    func signUpWithEmail(email: String, password: String, completion: @escaping(Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result {
                completion(.success(result))
            }
        }
    }
    
    func checkUserDataExistence(uid: String, completion: @escaping(DocumentSnapshot?, Error?) -> Void){
        let db = Firestore.firestore()
        let userCollection = db.collection("Users")
        userCollection.document(uid).getDocument { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(result, nil)
        }
    }
}
