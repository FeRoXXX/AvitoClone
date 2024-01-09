//
//  FireLoadData.swift
//  NewProject
//
//  Created by Александр Федоткин on 30.12.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class FireLoadData {
    static let shared = FireLoadData()
    
    private init() {
        
    }
    
    func loadRegisterData(db: Firestore, requestData: [String : Any]) async throws {
        guard let userId = UserAuthData.shared.uid else { return } //TODO: - alert
        try await db.collection("Users").document(userId).setData(requestData)
    }
    
    func loadPhotoToCurrentUserData(db: Firestore, requestData: [String : Any], completion: @escaping(Error?) -> Void) {
        db.collection("Users").document(UserAuthData.shared.uid!).setData(requestData, merge: true)
    }
    
    func downloadURLImage(imageReference: StorageReference, completion: @escaping(Result<URL, Error>) -> Void) {
        imageReference.downloadURL { result in
            switch result {
            case .success(_):
                completion(result)
            case .failure(_):
                completion(result)
            }
        }
    }
    
    func uploadProfileImage(reference: StorageReference, data: Data, completion: @escaping(Result<StorageMetadata, Error>) -> Void) {
        reference.putData(data) { result in
            switch result {
            case .success(_):
                print("Photo is uploaded") // TODO: - success bar
                completion(result)
            case .failure(let error):
                print(error.localizedDescription) //TODO: - alert
                completion(result)
            }
        }
    }
    
}
