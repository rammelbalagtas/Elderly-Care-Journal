//
//  Shift.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation

struct Shift: Codable {
    let id: String
    let memberId: String
    var description: String
    var fromDateTime: String
    var toDateTime: String
    var tasks: [Task]
    var uid: String
}
