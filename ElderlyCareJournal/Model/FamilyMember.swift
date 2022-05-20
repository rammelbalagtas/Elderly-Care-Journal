//
//  FamilyMember.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import Foundation

struct FamilyMember: Codable {
    
    let uid: String
    let memberId: String
    var firstName: String
    var lastName: String
    var age: Int
    var gender: Gender.RawValue
    var street: String
    var provinceCity: String
    var postalCode: String
    var country: String
    var emergencyContactName: String
    var emergencyContactNumber: String
    var photo: String?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case memberId
        case firstName
        case lastName
        case age
        case gender
        case street
        case provinceCity
        case postalCode
        case country
        case emergencyContactName
        case emergencyContactNumber
        case photo
    }
    
}
