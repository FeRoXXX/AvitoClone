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
    var date: String?
    var address: String?
    var userUUID: String?
    var checkedLikeImage: Bool? = false
    
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
        if let uuid = data[index]["UUID"] as? String{
            self.uuid = UUID(uuidString: uuid)
        }
        if let userUUID = data[index]["UserID"] as? String {
            self.userUUID = userUUID
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
        if let date = data[index]["Date"] as? String {
            self.date = date
        }
        if let address = data[index]["Address"] as? String? {
            self.address = address
        }
        if let imageURLArray = data[index]["Images"] as? [String] {
            if let imageURL = imageURLArray.first{
                SDWebImageManager.shared.loadImage(with: URL(string: imageURL), progress: nil) { [weak self] image, imageData, error, cache, boolData, url in
                    if let error {
                        completion(.failure(error)) //TODO: - alert
                    }
                    if let image {
                        self?.image = image
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
    
    func addLikeToPublication(postID: UUID, userID: String) async throws {
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
                        try await checkLike(postID: postID, userID: userID)
                    } else {
                        var usersArrayCorrected = usersArray
                        usersArrayCorrected.append(userID)
                        let data = ["UserID" : usersArrayCorrected]
                        try await dbURL.setData(data)
                        try await checkLike(postID: postID, userID: userID)
                    }
                }
            } else {
                let data = ["UserID" : [userID]]
                try await dbURL.setData(data)
                try await checkLike(postID: postID, userID: userID)
            }
        } catch {
            throw error
        }
    }
    func checkLike(postID: UUID, userID: String) async throws {
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("likes").collection("all").document(postID.uuidString)
        do {
            let results = try await dbURL.getDocument()
            if let result = results.data() {
                if let usersArray = result["UserID"] as? [String] {
                    if usersArray.contains(userID) {
                        self.checkedLikeImage = true
                    } else {
                        self.checkedLikeImage = false
                    }
                }
//                print("id: \(uuid)")
//                print("userID: \(userID)")
            } else {
                self.checkedLikeImage = true
            }
        } catch {
            throw error
        }
    }
//    deinit {
//        print("ok")
//        uuid = nil
//        name = nil
//        information = nil
//        price = nil
//        image = nil
//        category = nil
//        date = nil
//        address = nil
//    }
}
