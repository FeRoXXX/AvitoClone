//
//  ReceivedCurrentPost.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import SDWebImage

class ReceivedCurrentPost {
    
    var data = [String : Any]()
    var uuid: UUID?
    var name: String?
    var information: String?
    var price: String?
    var image = [UIImage]()
    var category: String?
    var userID: String?
    
    init(uuidCurrentPost: UUID) async throws {
        do{
            let snapshot = try await getPost(uuidCurrentPost: uuidCurrentPost)
            if let data = snapshot.data() {
                self.data = data
            }
        } catch {
            throw error
        }
    }
    
    private func getPost(uuidCurrentPost: UUID) async throws -> DocumentSnapshot{
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("products").collection("all").document(uuidCurrentPost.uuidString)
        
        do {
            let results = try await dbURL.getDocument()
            return results
        } catch {
            throw error
        }
    }
    
    private func deleteImage() async throws {
        guard let userID = self.userID, let uuid = self.uuid else { return }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let images = storageRef.child("media/posts/\(userID)/\(uuid.uuidString)")
        do {
            let results = try await images.listAll()
            
            for item in results.items {
                do {
                    try await item.delete()
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
    
    func deletePost() async throws {
        guard let uuid = self.uuid else { return }
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("products").collection("all").document(uuid.uuidString)
        do {
            try await deleteImage()
        } catch {
            throw error
        }
        
        do {
            try await dbURL.delete()
        } catch {
            throw error
        }
    }
    
    func dictionaryToVariables(completion: @escaping (Result<Bool, Error>) -> Void) {
        if let uuid = data["UUID"] as? String{
            self.uuid = UUID(uuidString: uuid)
        }
        if let userID = data["UserID"] as? String {
            self.userID = userID
        }
        if let name = data["Name"] as? String {
            self.name = name
        }
        if let price = data["Price"] as? String {
            self.price = price
        }
        if let information = data["Information"] as? String {
            self.information = information
        }
        if let imageURLArray = data["Images"] as? [String] {
            for imageURL in imageURLArray {
                SDWebImageManager.shared.loadImage(with: URL(string: imageURL), progress: nil) { image, imageData, error, cache, boolData, url in
                    if let error {
                        completion(.failure(error)) //TODO: - alert
                    }
                    if let image {
                        self.image.append(image)
                        completion(.success(true))
                    }
                }
            }
        }
    }
}
