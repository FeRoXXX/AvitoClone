//
//  ReceivedCurrentPost.swift
//  NewProject
//
//  Created by Александр Федоткин on 12.01.2024.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class ReceivedCurrentPost {
    
    var data = [String : Any]()
    var uuid: UUID?
    var name: String?
    var information: String?
    var price: String?
    var image = [UIImage]()
    var category: String?
    
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
    
    func dictionaryToVariables(completion: @escaping (Result<Bool, Error>) -> Void) {
        if let uuid = data["UUID"] as? String{
            self.uuid = UUID(uuidString: uuid)
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
