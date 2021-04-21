//
//  JoinRoomCell.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/21/21.
//

import UIKit

class JoinRoomCell: UITableViewCell {
    // MARK: - Properties
    static let cellIdentifier = "JoinRoomCell"
    
    let roomLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    let rssiLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier:String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func setupUI(){
        backgroundColor = .white
        setupStack()
    }
    
    private func setupStack(){
        let stack = UIStackView(arrangedSubviews: [roomLabel, rssiLabel])
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,  paddingLeft: 17, paddingRight: 17)
    }
}
