//
//  UUID+Extensions.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/21/21.
//

import Foundation

extension UUID {
    static func generateRoomID() -> String {
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let index = uuid.index(uuid.endIndex, offsetBy: -17)
        return String(uuid.suffix(from: index))
    }
}
