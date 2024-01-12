//
//  ReceivedAllPosts.swift
//  NewProject
//
//  Created by Александр Федоткин on 09.01.2024.
//

import UIKit
import SDWebImage
import FirebaseFirestore

class ReceivedAllPosts {
    
    var data = [[String : Any]]()
    var uuid: UUID?
    var name: String?
    var information: String?
    var price: String?
    var image: UIImage?
    var category: String?
    
    init() async throws {
        
        do{
            let snapshot = try await getAllUserPosts()
            
            for document in snapshot.documents {
                self.data.append(document.data())
            }
        } catch {
            throw error
        }
    }
    init(text: String) async throws {
        do{
            let snapshot = try await getAllUserPostsSorted(text)
            
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
    
    private func getAllUserPosts() async throws -> QuerySnapshot{
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("products").collection("all")
        
        do {
            let results = try await dbURL.getDocuments()
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
    
    private func getAllUserPostsSorted(_ text: String) async throws -> QuerySnapshot{
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("products").collection("all").whereField("Name", isEqualTo: text)
        
        do {
            let results = try await dbURL.getDocuments()
            return results
        } catch {
            throw error
        }
    }
}
