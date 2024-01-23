//
//  UserPosts.swift
//  NewProject
//
//  Created by Александр Федоткин on 06.01.2024.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class UploadNewPost {
    
    let uuid: UUID
    let name: String
    let information: String
    let price: String
    let imagesArray: [UIImage]
    let category: String
    let number: String
    let date: String
    let address: String
    
    init(name: String, information: String, price: String, imagesArray: [UIImage], category: String, number: String, date: String, address: String, uuidOpt: UUID? = nil) {
        if let uuid = uuidOpt {
            self.uuid = uuid
        } else {
            self.uuid = UUID()
        }
        self.name = name
        self.information = information
        self.price = price
        self.imagesArray = imagesArray
        self.category = category
        self.number = number
        self.date = date
        self.address = address
    }
    
    func sendImageToStorage(userID: String, completion: @escaping (_ status: Bool, _ response: String) -> Void) { //TODO: - send images to Storage
        imagesArray.enumerated().forEach { (index, image) in
            guard let data = image.jpegData(compressionQuality: 0.5) else {
                completion(false, "Unable to get data from image")
                return
            }
            
            let storage = Storage.storage()
            let url = storage.reference().child("media/posts/\(userID)/\(uuid.uuidString)/\(index).jpg")
            let _ = url.putData(data) { metadata, error in
                guard let _ = metadata else {
                    completion(false, error?.localizedDescription ?? "Error")
                    return
                }
                
                url.downloadURL { url, error in
                    guard let downloadURL = url else {
                        completion(false, error?.localizedDescription ?? "Error")
                        return
                    }
                    completion(true, downloadURL.absoluteString)
                }
            }
        }
    }
    
    func sendPostDataToFirebase(downloadURL: [String], userID: String) async throws {
        let db = Firestore.firestore()
        let dbURL = db.collection("Posts").document("\(category)/all/\(uuid.uuidString)")
        let data = ["UserID" : userID, "UUID" : uuid.uuidString, "Name" : name, "Information" : information, "Images" : downloadURL, "Number" : number, "Date" : date, "Address" : address, "Price" : price] as [String : Any]
        try await dbURL.setData(data)
    }
}
