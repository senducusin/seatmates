//
//  Room.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import Foundation
import CoreBluetooth

class Room {
    var peripheral: CBPeripheral
    var rssi: NSNumber
    var advertisementData: [String:Any]
    
    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: [String:Any]){
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
    }
}
