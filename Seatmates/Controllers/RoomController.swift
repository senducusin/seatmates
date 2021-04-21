//
//  NewRoomController.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import UIKit

class RoomController: UIViewController{
    // MARK: - Properties
    var blePeripheral: BLEPeripheral?
//    var bleCentral: BLECentralManager?
    var roomAdmin = false
    let user = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(sendHandler), for: .touchUpInside)
        button.setTitle("Send", for: .normal)
        button.backgroundColor = .white
        return button
    }()
    
    private let textView: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .lightGray
        textfield.textColor = .white
        return textfield
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if roomAdmin {
            blePeripheral = BLEPeripheral()
        }
        
        setupUI()
    }
    
    // MARK: - Selectors
    @objc private func sendHandler(){
        guard let messageContent = textView.text else { return }
        let message = Message(sender: user, message: messageContent, timestamp: Date())
        
        print("send handler??")
        
        if roomAdmin {
            if let blePeripheral = blePeripheral {
                blePeripheral.sendMessage(withMessage: message)
            }
        }else{
//            if let bleCentral = bleCentral {
//                print("send handler?")
            BLECentralManager.shared.sendMessageToPeripheral(withMessage: message)
//            }
        }
        
    }
    
    // MARK: - Helpers
    private func setupUI(){
        view.backgroundColor = .white
        title = "Seatmates"
        setupButton()
        setupTextfield()
    }
    
    private func setupTextfield(){
        view.addSubview(textView)
        textView.centerX(inView: view)
        textView.anchor(bottom:sendButton.topAnchor, paddingBottom: 10, width: 300, height: 50)
    }
    
    private func setupButton(){
        view.addSubview(sendButton)
        sendButton.centerX(inView: view)
        sendButton.centerY(inView: view)
        sendButton.setDimensions(height: 50, width: 100)
    }
}
