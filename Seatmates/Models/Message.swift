//
//  Message.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import Foundation

struct Message:Codable{
    var sender: String
    var message: String
    var timestamp: Date
}
