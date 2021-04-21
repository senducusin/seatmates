//
//  RoomController.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import UIKit

class RoomController: UICollectionViewController{
    // MARK: - Properties
    private let user: String
    private let roomAdmin: Bool
    
    private var host: String!
    var conversations = [Conversation]()
    var blePeripheral: BLEPeripheral?
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let inputView = CustomInputAccessoryView(frame: .zero)
        inputView.delegate = self
        return inputView
    }()
    
    
    // MARK: - Lifecycle
    init(user: String, roomAdmin: Bool){
        self.user = user
        self.roomAdmin = roomAdmin
        
        if roomAdmin {
            host = user
            blePeripheral = BLEPeripheral(roomID: user)
        }else{
            host = BLECentralManager.shared.getRoomName()
        }
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default
            .removeObserver(self, name: NSNotification.Name.newMessageFromCentral, object: nil)
        
        NotificationCenter.default
            .removeObserver(self, name: NSNotification.Name.newMessageFromPeripheral, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if roomAdmin {
            NotificationCenter.default
                .addObserver(self,
                             selector:#selector(newMessage(_:)),
                             name: NSNotification.Name.newMessageFromPeripheral,                                           object: nil)
        }else{
            NotificationCenter.default
                .addObserver(self,
                             selector:#selector(newMessage(_:)),
                             name: NSNotification.Name.newMessageFromCentral,                                           object: nil)
        }
        setupUI()
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Selectors
    @objc private func newMessage(_ notification:Notification){
        guard let message = notification.userInfo?["userInfo"] as? Message else {return}
        
        let conversation = Conversation(message, recepientId: user, isFromCurrentUser: false)
        conversations.append(conversation)
        collectionView.reloadData()
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    private func setupUI(){
        collectionView.backgroundColor = .white
        
        title = "\(String(user.prefix(10)))..."
        
        collectionView.register(RoomCell.self, forCellWithReuseIdentifier: RoomCell.cellIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
    }
}

extension RoomController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoomCell.cellIdentifier, for: indexPath) as! RoomCell
        
        cell.message = conversations[indexPath.row]
        
        return cell
    }
}

extension RoomController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let estimatedSizeCell = RoomCell(frame:frame)
        
        let message = conversations[indexPath.row]
        
        estimatedSizeCell.message = message
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    //    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        collectionView.deselectItem(at: indexPath, animated: true)
    //
    //        let message = messages[indexPath.row]
    //    }
}

extension RoomController: CustomInputAccessoryViewDelegate {
    
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend content: String) {
        
        let message = Message(fromID: user, content: content)
        if roomAdmin {
            guard let peripheral = blePeripheral else {return}
            peripheral.sendMessage(withMessage: message)
            
            let conversation = Conversation(message, recepientId: user, isFromCurrentUser: true)
            conversations.append(conversation)
            collectionView.reloadData()
        }else{
            
            BLECentralManager.shared.sendMessageToPeripheral(withMessage: message)
            
            guard let recepientId = BLECentralManager.shared.getRoomName() else {return}
            
            let conversation = Conversation(message, recepientId: recepientId, isFromCurrentUser: true)
            conversations.append(conversation)
            collectionView.reloadData()
        }
        
        inputView.clearMessageText()
        
    }
}

