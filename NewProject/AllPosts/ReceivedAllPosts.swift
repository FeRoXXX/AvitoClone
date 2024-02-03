//
//  ReceivedAllPosts.swift
//  NewProject
//
//  Created by Александр Федоткин on 09.01.2024.
//

import UIKit
import SDWebImage
import FirebaseFirestore
import FirebaseAuth

class ReceivedAllPosts {
    
    var postsArray : [AllPostsData] = []
    
    init() async throws {
        do{
            let snapshot = try await getAllUserPosts()
            
            for document in snapshot.documents {
                await dictionaryToVariables(data: document.data())
                
                guard self.postsArray.count > 0 else { continue }
                let index = self.postsArray.count - 1
                try await self.checkLike(index: index)
            }
        } catch {
            throw error
        }
    }
    init(sort: Bool = true, sortString: String) async throws {
        do{
            let snapshot = try await getAllUserPostsSorted(sortString)
            
            for document in snapshot.documents {
                await dictionaryToVariables(data: document.data())
                
                guard self.postsArray.count > 0 else { continue }
                let index = self.postsArray.count - 1
                try await self.checkLike(index: index)
            }
        } catch {
            throw error
        }
    }
    init(text: String) async throws {
        do{
            let snapshot = try await getAllUserPostsSorted(text)
            
            for document in snapshot.documents {
                await dictionaryToVariables(data: document.data())
                guard self.postsArray.count > 0 else { continue }
                let index = self.postsArray.count - 1
                do {
                    try await self.checkLike(index: index)
                } catch {
                    throw error
                }
            }
        } catch {
            throw error
        }
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
    
    func dictionaryToVariables(data: [String : Any]) async {
        guard let uuid = data["UUID"] as? String,
              let userUUID = data["UserID"] as? String,
              let name = data["Name"] as? String,
              let price = data["Price"] as? String,
              let information = data["Information"] as? String,
              let date = data["Date"] as? String,
              let address = data["Address"] as? String,
              let imageURLArray = data["Images"] as? [String],
              let imageURL = imageURLArray.first else { return }
        
            self.postsArray.append(AllPostsData(uuid: UUID(uuidString: uuid),
                                                name: name,
                                                information: information,
                                                price: price,
                                                imageURL: imageURL,
                                                category: "Products",
                                                date: date,
                                                address: address,
                                                userUUID: userUUID,
                                                checkedLikeImage: false))
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
    
    func addLikeToPublication(index: Int) async throws {
        guard let userID = Auth.auth().currentUser?.uid,
              let postID = postsArray[index].uuid else { return }
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("likes").collection("all").document(postID.uuidString)
        do {
            let results = try await dbURL.getDocument()
            if let result = results.data() {
                if let usersArray = result["UserID"] as? [String] {
                    if usersArray.contains(userID) {
                        let usersArrayCorrected = usersArray.filter{ $0 != userID}
                        let data = ["UserID" : usersArrayCorrected]
                        try await dbURL.setData(data)
                        try await checkLike(index: index)
                    } else {
                        var usersArrayCorrected = usersArray
                        usersArrayCorrected.append(userID)
                        let data = ["UserID" : usersArrayCorrected]
                        try await dbURL.setData(data)
                        try await checkLike(index: index)
                    }
                }
            } else {
                let data = ["UserID" : [userID]]
                try await dbURL.setData(data)
                try await checkLike(index: index)
            }
        } catch {
            throw error
        }
    }
    func checkLike(index: Int) async throws {
        guard let userID = Auth.auth().currentUser?.uid,
              let postID = postsArray[index].uuid else { return }
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("likes").collection("all").document(postID.uuidString)
        do {
            let results = try await dbURL.getDocument()
            if let result = results.data() {
                if let usersArray = result["UserID"] as? [String] {
                    if usersArray.contains(userID) {
                        self.postsArray[index].checkedLikeImage = true
                    } else {
                        self.postsArray[index].checkedLikeImage = false
                    }
                }
            } else {
                self.postsArray[index].checkedLikeImage = false
            }
        } catch {
            throw error
        }
    }
    func checkLikedPostsForFavourite() async throws -> [String] {
        guard let userID = UserAuthData.shared.uid else { return [] }
        var postsID = [String]()
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("likes").collection("all")
        do {
            let results = try await dbURL.getDocuments()
            for result in results.documents {
                let likesDictionary = result.data()
                if let likesArray = likesDictionary["UserID"] as? [String] {
                    if likesArray.contains(userID) {
                        postsID.append(result.documentID)
                    }
                }
            }
            return postsID
        } catch {
            throw error
        }
    }
}
