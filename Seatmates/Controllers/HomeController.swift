//
//  HomeController.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import UIKit

class HomeController: UIViewController {
    // MARK: - Properties
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .italicSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.text = "To start with Seatmates, the user can either start by creating a chat room or by joining an existing chat room."
        return label
    }()
    
    private lazy var createRoomButton: HomeButton = {
        let button = HomeButton(type: .system)
        button.title = "Create a room"
        button.addTarget(self, action: #selector(createRoomHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var joinRoomButton: UIButton = {
        let button = HomeButton(type: .system)
        button.title = "Join a room"
        button.addTarget(self, action: #selector(joinRoomHandler), for: .touchUpInside)
        return button
    }()
    
    private let dividerView = DividerView(frame: .zero)
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Selectors
    @objc private func createRoomHandler(){
        let controller = RoomController()
        controller.roomAdmin = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func joinRoomHandler(){
        let controller = JoinRoomController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Helpers
    private func setupUI(){
        view.backgroundColor = .white
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupLabel()
        setupDividerView()
        setupCreateRoomButton()
        setupJoinRoomButton()
    }
    
    private func setupLabel(){
        view.addSubview(label)
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 5,  paddingRight: 5)
    }
    
    private func setupDividerView(){
        view.addSubview(dividerView)
        dividerView.centerX(inView: view)
        dividerView.centerY(inView: view)
        dividerView.setDimensions(height: 50, width: 100)
    }
    
    private func setupCreateRoomButton(){
        view.addSubview(createRoomButton)
        createRoomButton.centerX(inView: view)
        createRoomButton.anchor(bottom: dividerView.topAnchor, paddingBottom: 10)
    }
    
    private func setupJoinRoomButton(){
        view.addSubview(joinRoomButton)
        joinRoomButton.centerX(inView: view)
        joinRoomButton.anchor(top: dividerView.bottomAnchor, paddingTop: 10)
    }
}
