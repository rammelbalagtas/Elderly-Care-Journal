//
//  FamilyMember.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-18.
//

import Foundation

struct FamilyMember: Codable {
    
    let memberId: String
    let uid: String
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
    var documents: [Document]
    
}
