//
//  FireGetData.swift
//  NewProject
//
//  Created by Александр Федоткин on 30.12.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage

class FireGetData {
    static let shared = FireGetData()
    
    func getUserDataFromFirestore(uid: String) async throws -> DocumentSnapshot {
        let db = Firestore.firestore()
        let userCollection = db.collection("Users")

        let document = try await userCollection.document(uid).getDocument()
        return document
    }
    
    func getData(uid: String, completion: @escaping (Result<DocumentSnapshot, Error>) -> Void) {
        Task {
            do {
                let result = try await getUserDataFromFirestore(uid: uid)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getDataFromUserBase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        FireGetData.shared.getData(uid: uid) { (result: Result<DocumentSnapshot, Error>) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let result):
                if let convertData = result.data() {
                    UserAuthData.shared.name = convertData["Name"] as? String
                    UserAuthData.shared.city = convertData["City"] as? String
                    UserAuthData.shared.organizationName = convertData["Organization"] as? String
                    UserAuthData.shared.registrationYear = convertData["RegistrationYear"] as? Int
                    if let imageURL = convertData["imageURL"] as? String {
                        SDWebImageManager.shared.loadImage(with: URL(string: imageURL), progress: nil) { image, imageData, error, cache, boolData, url in
                            if let error {
                                print(error.localizedDescription) //TODO: - alert
                            }
                            if let image {
                                UserAuthData.shared.profilePhoto = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        print("FireGetData was deinited")
    }
    
}
