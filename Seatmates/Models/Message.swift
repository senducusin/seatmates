//
//  Message\.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/21/21.
//

import Foundation

struct Message:Codable {
    let fromID: String
    let content: String
    var date: Date = Date()
}
