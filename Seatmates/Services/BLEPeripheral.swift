//
//  BLEPeripheral.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import Foundation
import CoreBluetooth

class BLEPeripheral: NSObject {
    
    // MARK: - Properties
    private var manager: CBPeripheralManager?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private lazy var messageCharacteristics: CBMutableCharacteristic = {
        let characteristicUUID = CBUUID(string: BLEIdentifiers.messageCharacteristicsUUID)
        return CBMutableCharacteristic(type: characteristicUUID, properties: [.read, .writeWithoutResponse, .notify], value: nil, permissions: [.readable, .writeable])
    }()
    
    // MARK: - Lifecycles
    override init() {
        super.init()
        manager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Helpers
    func setup(){
        let messageDescriptor = CBMutableDescriptor(type: CBUUID(string: CBUUIDCharacteristicUserDescriptionString), value: "Seatmate Messaging")
        messageCharacteristics.descriptors = [messageDescriptor]
        
        let serviceUUID = CBUUID(string: BLEIdentifiers.serviceIdentifierUUID)
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        service.characteristics = [messageCharacteristics]
        manager?.add(service)
    }
    
    func sendMessage(withMessage message:Message){
        if let payload = try? encoder.encode(message) {
            messageCharacteristics.value = payload
            manager?.updateValue(payload, for: messageCharacteristics, onSubscribedCentrals: nil)
        }
    }
    
}

// MARK: - CBPeripheralManagerDelegate
extension BLEPeripheral: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            setup()
            
        }else {
            print("DEBUG: peripheral is not available \(peripheral.state.rawValue)")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let advertisementData: [String:Any] = [
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: BLEIdentifiers.serviceIdentifierUUID)],
            CBAdvertisementDataLocalNameKey: "Seatmate-\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        ]
        
        manager?.startAdvertising(advertisementData)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("DEBUG: error in advertising = \(error.localizedDescription)")
            return
        }
        print("DEBUG: Created a room")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("DEBUG: Did receive read request: \(request)")
        
        if !request.characteristic.uuid.isEqual(messageCharacteristics.uuid) {
            peripheral.respond(to: request, withResult: .requestNotSupported)
        }else {
            guard let value = messageCharacteristics.value else {
                peripheral.respond(to: request, withResult: .invalidAttributeValueLength)
                return
            }
            
            if request.offset > value.count {
                peripheral.respond(to: request, withResult: .invalidOffset)
            }else{
                request.value = value.subdata(in: request.offset ..< value.count - request.offset)
                peripheral.respond(to: request, withResult: .success)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("DEBUG: received request")
        
        requests.forEach { request in
            guard let data = request.value else {return}
            if let extractedValue = try? decoder.decode(Message.self, from:data){
                print("DEBUG: value = \(extractedValue)")
                
            }
        }
    }
}
