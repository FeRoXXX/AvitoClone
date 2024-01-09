//
//  UserAuthData.swift
//  NewProject
//
//  Created by Александр Федоткин on 28.12.2023.
//

import UIKit
import FirebaseAuth

class UserAuthData {
    static let shared = UserAuthData()
    var email: String?
    var uid: String?
    var name: String?
    var registrationYear: Int?
    var city: String?
    var profilePhoto: UIImage?
    var organizationName: String?
    
    private init() {
    }
    
    func reset() {
        email = ""
        uid = ""
        name = ""
        city = ""
        registrationYear = nil
        profilePhoto = nil
        organizationName = ""
    }
    
}
