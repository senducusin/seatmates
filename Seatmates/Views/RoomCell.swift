//
//  RoomCell.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/21/21.
//

import UIKit

class RoomCell: UICollectionViewCell {
    // MARK: - Properties
    var message :Conversation? {
        didSet {configure()}
    }
    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!
    
    static let cellIdentifier = "RoomCell"
    
    private let profileImageLabel: UILabel = {
        let label = UILabel()
        label.contentMode = .scaleAspectFill
        label.clipsToBounds = true
        label.backgroundColor = .darkGray
        label.tintColor = .lightGray
        label.textColor = .white
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textColor = .white
        textView.isHidden = true
        
        return textView
    }()
    
    private lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.layer.cornerRadius = 13
        imageView.setDimensions(height: 155, width: 220)
        return imageView
    }()
    
    private let bubbleContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect){
        super.init(frame: frame)
//        self.backgroundColor = .gree
        
        self.addSubview(self.profileImageLabel)
        self.profileImageLabel.anchor(left:leftAnchor, bottom: bottomAnchor, paddingLeft: 8, paddingBottom: -4)
        self.profileImageLabel.setDimensions(height: 32, width: 32)
        self.profileImageLabel.layer.cornerRadius = 32/2
        
        addSubview(self.bubbleContainer)
        self.bubbleContainer.layer.cornerRadius = 16
        self.bubbleContainer.anchor(top:topAnchor, bottom: bottomAnchor)
        self.bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        /// Left Anchor
        self.bubbleLeftAnchor = self.bubbleContainer.leftAnchor.constraint(equalTo: self.profileImageLabel.rightAnchor, constant: 12)
        self.bubbleLeftAnchor.isActive = false
        
        /// Right Anchor
        self.bubbleRightAnchor = self.bubbleContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12)
        self.bubbleRightAnchor.isActive = false
        
        self.bubbleContainer.addSubview(self.textView)
        self.textView.anchor(
            top:self.bubbleContainer.topAnchor,
            left:self.bubbleContainer.leftAnchor,
            bottom: self.bubbleContainer.bottomAnchor,
            right: self.bubbleContainer.rightAnchor,
            paddingLeft: 6,
            paddingRight: 6
        )

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    func configure(){
        guard let message = message else {return}
        let viewModel = MessageViewModel(message: message)
        
        self.bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        
        self.textView.textColor = .white
        
        self.textView.isHidden = false
        self.messageImageView.removeFromSuperview()
        self.textView.text = message.content
        self.profileImageLabel.text = String(message.fromID.prefix(1))

        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        
        profileImageLabel.isHidden = viewModel.shouldHideProfileImage
    }
    
    private func setupMessageImageView(_ imageUrl:URL){
        
        self.messageImageView.setDimensions(height: 155, width: 220)
        self.bubbleContainer.addSubview(self.messageImageView)
        self.messageImageView.anchor(
            top:self.bubbleContainer.topAnchor,
            left: self.bubbleContainer.leftAnchor,
            bottom: self.bubbleContainer.bottomAnchor,
            right:self.bubbleContainer.rightAnchor,
            paddingTop: 8,
            paddingLeft: 8,
            paddingBottom: 8,
            paddingRight: 8
        )
    }
}

