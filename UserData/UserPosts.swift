//
//  UserPosts.swift
//  NewProject
//
//  Created by Александр Федоткин on 08.01.2024.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class UserPosts {
    
    var data = [[String : Any]]()
    var uuid: UUID?
    var name: String?
    var information: String?
    var price: String?
    var image: UIImage?
    var category: String?
    
    init(userID: String) async throws {
        
        do{
            let snapshot = try await getAllUserPosts(userID)
            
            for document in snapshot.documents {
                self.data.append(document.data())
            }
        } catch {
            throw error
        }
    }
    
    init(postData: [[String : Any]]) {
        self.data = postData
    }
    
    private func getAllUserPosts(_ userID: String) async throws -> QuerySnapshot{
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("products").collection("all")
        
        do {
            let results = try await dbURL.whereField("UserID", isEqualTo: userID).getDocuments()
            return results
        } catch {
            throw error
        }
    }
    
    func dictionaryToVariables(index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        if let uuid = data[index]["UUID"] as? UUID {
            self.uuid = uuid
        }
        if let name = data[index]["Name"] as? String {
            self.name = name
        }
        if let price = data[index]["Price"] as? String {
            self.price = price
        }
        if let information = data[index]["Information"] as? String {
            self.information = information
        }
        if let imageURLArray = data[index]["Images"] as? [String] {
            if let imageURL = imageURLArray.first{
                SDWebImageManager.shared.loadImage(with: URL(string: imageURL), progress: nil) { image, imageData, error, cache, boolData, url in
                    if let error {
                        completion(.failure(error)) //TODO: - alert
                    }
                    if let image {
                        self.image = image
                        completion(.success(true))
                    }
                }
            }
        }
    }
}
