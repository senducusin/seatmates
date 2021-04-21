//
//  Message.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import Foundation

struct Conversation:Codable{
    let content: String
    let toID: String
    let fromID: String
    var date: Date = Date()
    let isFromCurrentUser: Bool
}

extension Conversation {
    init(_ message: Message, recepientId: String, isFromCurrentUser: Bool){
        content = message.content
        toID = recepientId
        fromID = message.fromID
        date = message.date
        self.isFromCurrentUser = isFromCurrentUser
    }
}
