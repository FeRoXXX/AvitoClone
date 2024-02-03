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
    var postsArray: [UserPostsData] = []
    
    init(userID: String) async throws {
        
        do{
            let snapshot = try await getAllUserPosts(userID)
            
            for document in snapshot.documents {
                await dictionaryToVariables(document.data())
                //self.data.append(document.data())
            }
        } catch {
            throw error
        }
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
    
    func dictionaryToVariables(_ data: [String : Any]) async {
        guard let uuid = data["UUID"] as? String,
              let name = data["Name"] as? String,
              let price = data["Price"] as? String,
              let information = data["Information"] as? String,
              let date = data["Date"] as? String,
              let address = data["Address"] as? String,
              let imageURLArray = data["Images"] as? [String],
              let imageURL = imageURLArray.first else { return }
        
        self.postsArray.append(UserPostsData(uuid: UUID(uuidString: uuid),
                                             name: name,
                                             information: information,
                                             price: price,
                                             imageURL: imageURL,
                                             category: "products",
                                             date: date,
                                             address: address))
    }
}
