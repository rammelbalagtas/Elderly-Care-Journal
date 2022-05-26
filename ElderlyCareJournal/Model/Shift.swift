//
//  Shift.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-25.
//

import Foundation

struct Shift: Codable {
    var id: String
    var memberId: String
    var description: String
    var fromDateTime: String
    var toDateTime: String
    var tasks: [Task]
    var status: String
    var uid: String
//    enum CodingKeys: String, CodingKey {
//        case id
//        case memberId
//        case description
//        case fromDateTime
//        case toDateTime
//        case tasks
//        case uid
//    }
}
