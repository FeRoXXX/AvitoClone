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
    
    var currentPost : CurrentPostData? = nil
    
    init(uuidCurrentPost: UUID) async throws {
        do{
            let snapshot = try await getPost(uuidCurrentPost: uuidCurrentPost)
            if let data = snapshot.data() {
                await dictionaryToVariables(data: data)
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
        guard let currentPost = currentPost,
              let userID = currentPost.userID,
              let uuid = currentPost.uuid else { return }
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
        guard let currentPost = currentPost,
              let uuid = currentPost.uuid else { return }
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
    
    func dictionaryToVariables(data: [String : Any]) async {
        guard let uuid = data["UUID"] as? String,
              let userUUID = data["UserID"] as? String,
              let name = data["Name"] as? String,
              let price = data["Price"] as? String,
              let information = data["Information"] as? String,
              let number = data["Number"] as? String,
              let date = data["Date"] as? String,
              let address = data["Address"] as? String,
              let imageURLArray = data["Images"] as? [String] else { return }
        
        currentPost = CurrentPostData(uuid: UUID(uuidString: uuid), 
                                      name: name,
                                      information: information,
                                      price: price,
                                      image: imageURLArray,
                                      category: "products",
                                      userID: userUUID,
                                      number: number,
                                      address: address,
                                      date: date)
    }
}
