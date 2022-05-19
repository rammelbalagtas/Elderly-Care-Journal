//
//  Constants.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-16.
//

import Foundation

struct Constants {
    
    struct Storyboard {
        static let familyMemberListNavVC = "FamilyMemberListNavVC"
    }
    
    struct Database {
        static let users = "users"
        static let familyMembers = "familymembers"
    }
    
    //reuse identifier for custom nibs
    struct ReuseIdentifier {
        static let familyMemberTableViewCell = "FamilyMember"
    }
    
    //custom nib for table view/collection view cells
    struct NibName {
        static let nibFamilyMemberTable = "FamilyMemberTableViewCell"
    }
}

