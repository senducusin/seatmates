//
//  InputAccessoryView.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/21/21.
//

import Foundation
import UIKit

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend content:String)
}

class CustomInputAccessoryView: UIView {
    // MARK: - Properties
    var optionsViewSetToHide: NSLayoutConstraint!
    var optionsViewSetToShow: NSLayoutConstraint!
    
    private let messageInputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textColor = .black
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.systemTeal, for: .normal)
        button.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
        return button
    }()
     
    private let placeholderLabel: UILabel = {
        let label  = UILabel()
        label.text = "Type something"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect){
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        backgroundColor = .white
        
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 5
        layer.shadowOffset = .init(width: 0, height: -3)
        layer.shadowColor = UIColor.black.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
            self.setupSendButton()
            self.setupMessageInputTextView()
            self.setupPlaceholderLabel()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(messageInputDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // MARK: - Selectors
    @objc func sendButtonDidTap(){
        guard !messageInputTextView.text.isEmpty,
              let message = messageInputTextView.text
               else {return}
        delegate?.inputView(self, wantsToSend: message)
    }
    
    @objc func messageInputDidChange() {
        placeholderLabel.isHidden = !messageInputTextView.text.isEmpty
    }
    
    // MARK: - Helpers
    public func clearMessageText() {
        messageInputTextView.text = nil
        placeholderLabel.isHidden = false
    }
    
    private func setupSendButton(){
       addSubview(sendButton)
       sendButton.anchor(
        bottom: safeAreaLayoutGuide.bottomAnchor,
        right: rightAnchor,
        paddingBottom: -4,
        paddingRight: 5
       )
       sendButton.setDimensions(height: 50, width: 80)
    }
    
    private func setupMessageInputTextView(){
        addSubview(messageInputTextView)
        messageInputTextView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: safeAreaLayoutGuide.bottomAnchor,
            right: sendButton.leftAnchor,
            paddingTop: 12,
            paddingLeft: 12,
            paddingBottom: 4
        )
    }
    
    private func setupPlaceholderLabel(){
        addSubview(placeholderLabel)
        placeholderLabel.anchor(left: messageInputTextView.leftAnchor, paddingLeft: 4)
        placeholderLabel.centerY(inView: messageInputTextView)
    }

}
