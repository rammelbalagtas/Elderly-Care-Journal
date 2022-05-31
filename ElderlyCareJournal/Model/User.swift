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
    var firstName: String
    var lastName: String
    var age: Int?
    var gender: Gender.RawValue?
    var contactNumber: String?
    var street: String?
    var cityProvince: String?
    var postalCode: String?
    var country: String?
    var photo: String?
    
}
