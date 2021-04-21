//
//  MessageViewModel.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/21/21.
//

import UIKit

struct MessageViewModel {
    private let message: Conversation

    var messageBackgroundColor: UIColor{
        return message.isFromCurrentUser ? .systemTeal : .darkGray
    }

    var rightAnchorActive: Bool {
        return message.isFromCurrentUser
    }
    
    var leftAnchorActive: Bool {
        return !message.isFromCurrentUser
    }

    var shouldHideProfileImage: Bool {
            return message.isFromCurrentUser
        }
    
    init(message:Conversation){
        self.message = message
    }
}
