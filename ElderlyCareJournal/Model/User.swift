//
//  User.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-19.
//

import Foundation

struct User: Codable {
    
    let uid: String
    let emailAddress: String
    let userType: UserType.RawValue
    let firstName: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case emailAddress
        case userType
        case firstName
        case lastName
    }
    
}
