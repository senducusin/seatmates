//
//  JoinRoomController.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import UIKit

class JoinRoomController: UITableViewController {
    // MARK: - Properties
    private var rooms = [Room]()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        BLECentralManager.shared.start()
        BLECentralManager.shared.delegate = self
        setupTableView()
        setupUI()
    }
    
    // MARK: - Helpers
    private func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        title = "Join a Room"
    }
}

// MARK: - TableViewDataSource
extension JoinRoomController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let room = rooms[indexPath.row]
        
        if let roomName = room.advertisementData["kCBAdvDataLocalName"] as? String {
            cell.textLabel?.text = roomName
        }
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        BLECentralManager.shared.connectPeripheral(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension JoinRoomController: BLECentralManagerDelegate{
    func connectionStatusDidUpdate(status: Bool) {
        let user = UUID.generateRoomID()
        let controller = RoomController(user: user, roomAdmin: false)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func didUpdateRoom(rooms: [Room]) {
        self.rooms = rooms
        tableView.reloadData()
    }
    
    
}
