//
//  BLECentral.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import Foundation
import CoreBluetooth

protocol BLECentralManagerDelegate: class {
    func connectionStatusDidUpdate(status: Bool)
    func didUpdateRoom(rooms:[Room])
}
class BLECentralManager {
    static let shared = BLECentralManager()
    private var bleCentral: BLECentral!
    var onReceivedMessage:((Message)->())?
    
    weak var delegate: BLECentralManagerDelegate?
    
    func start(){
        bleCentral = BLECentral()
        
        bleCentral.connectionStatus = { [weak self] connected in
            self?.delegate?.connectionStatusDidUpdate(status: connected)
        }
        
        bleCentral.onDiscovered = { [weak self] rooms in
            self?.delegate?.didUpdateRoom(rooms: rooms)
        }
        
        bleCentral.onReceivedMessage = { newMessage in
            NotificationCenter.default
                .post(name: NSNotification.Name.newMessageFromCentral,
                      object: nil,
                      userInfo: ["userInfo":newMessage])
        }
        
    }
    
    func connectPeripheral(at index:Int){
        bleCentral.connect(at: index)
    }
    
    func sendMessageToPeripheral(withMessage message:Message){
        bleCentral.sendMessage(withMessage: message)
    }
    
    func getRoomName()->String? {
        return bleCentral.connectedRoomID
    }
    
    
}

class BLECentral: NSObject{
    // MARK: - Properties
    private var manager: CBCentralManager?
    private var discoveredRooms = [Room]()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var seatmateCharacteristic: CBCharacteristic?
    private var connectedPeripheral: CBPeripheral?
    
    var connectedRoomID: String?
    var onReceivedMessage: ((Message)->Void)?
    var connectionStatus: ((Bool)->Void)?
    var onDiscovered:(([Room])->Void)?
    
    // MARK: - Lifecycles
    override init(){
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Helpers
    private func scanForPeripherals(){
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey:false
        ]
        
        manager?.scanForPeripherals(withServices: [CBUUID(string: BLEIdentifiers.serviceIdentifierUUID)], options: options)
    }
    
    func connect(at index: Int){
        guard index >= 0,
              index < discoveredRooms.count else { return }
        
        manager?.stopScan()
        
        let room = discoveredRooms[index]
        
        manager?.connect(room.peripheral, options: nil)
        
        if let roomId = room.advertisementData["kCBAdvDataLocalName"] as? String {
            connectedRoomID = roomId
        }
    }
    
    func sendMessage(withMessage message:Message){
        print("DEBUG: trying to send")
        
        guard let peripheral = connectedPeripheral,
              let characteristic = seatmateCharacteristic else {
            print("DEBUG: error sending!")
            return
        }
        
        if let payload = try? encoder.encode(message){
            print("DEBUG: sending?")
            peripheral.writeValue(payload, for: characteristic, type: .withoutResponse)
        }else{
            print("DEBUG: error sending!")
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLECentral:CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if let existingPeripheral = discoveredRooms.first(where: {$0.peripheral == peripheral}){
            existingPeripheral.advertisementData = advertisementData
            existingPeripheral.rssi = RSSI
            
        }else{
            let discoveredRoom = Room(peripheral: peripheral, rssi: RSSI, advertisementData: advertisementData)
            discoveredRooms.append(discoveredRoom)
            
        }
        onDiscovered?(discoveredRooms)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            scanForPeripherals()
        }else {
            print("DEBUG: central is unavailable \(central.state.rawValue )")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        
        // nil ~> all available services on the peripheral
        connectedPeripheral?.discoverServices([CBUUID(string: BLEIdentifiers.serviceIdentifierUUID)])
        connectionStatus?(true)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectedRoomID = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BLECentral: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        peripheral.services?.forEach({ service in
            print("DEBUG: services = \(service)")
            peripheral.discoverCharacteristics([
                CBUUID(string: BLEIdentifiers.messageCharacteristicsUUID)
            ], for: service)
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        service.characteristics?.forEach({ characteristic in
            print("DEBUG: characteristic = \(characteristic)")
            
            if characteristic.properties.contains(.notify){
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == CBUUID(string: BLEIdentifiers.messageCharacteristicsUUID){
                print("DEBUG: happened?")
                seatmateCharacteristic = characteristic
            }
            
            peripheral.discoverDescriptors(for: characteristic)
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        characteristic.descriptors?.forEach({ descriptor in
            print("DEBUG: descriptor = \(descriptor)")
            peripheral.readValue(for: descriptor)
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        if let value = characteristic.value {
            if let message = try? decoder.decode(Message.self, from: value) {
                
                //                delegate?.didReceiveNewMessage(message: message)
                onReceivedMessage?(message)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print("DEBUG: updated descriptor = \(descriptor)")
    }
}
