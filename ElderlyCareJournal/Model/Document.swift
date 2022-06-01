//
//  Document.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-06-01.
//

import Foundation

struct Document: Codable {
    var name: String
    var path: String
    var contentType: String
    var size: Int64
    var createdOn: Date
}
