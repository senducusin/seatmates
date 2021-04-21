//
//  InputAccessoryView.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/21/21.
//

import Foundation
import UIKit

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message:String)
    func inputViewCameraUtilityDidTap()
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
        textView.textColor = .white
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
        label.textColor = .lightGray
        return label
    }()
    
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect){
        super.init(frame: frame)
        self.autoresizingMask = .flexibleHeight
        self.backgroundColor = .black
        
        self.layer.shadowOpacity = 0.35
        self.layer.shadowRadius = 15
        self.layer.shadowOffset = .init(width: 0, height: -8)
        self.layer.shadowColor = UIColor.black.cgColor
        
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
        guard !self.messageInputTextView.text.isEmpty,
              let message = self.messageInputTextView.text
               else {return}
        self.delegate?.inputView(self, wantsToSend: message)
    }
    
    @objc func messageInputDidChange() {
        self.placeholderLabel.isHidden = !self.messageInputTextView.text.isEmpty
    }
    
    @objc func cameraButtonDidTap(){
        self.delegate?.inputViewCameraUtilityDidTap()
    }
    
    // MARK: - Helpers
    public func clearMessageText() {
        self.messageInputTextView.text = nil
        placeholderLabel.isHidden = false
    }
    
    private func setupSendButton(){
        self.addSubview(self.sendButton)
        self.sendButton.anchor(bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingBottom: -4, paddingRight: 12)
        self.sendButton.setDimensions(height: 50, width: 50)
    }
    
    private func setupMessageInputTextView(){
        self.addSubview(self.messageInputTextView)
        self.messageInputTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 4)
    }
    
    private func setupPlaceholderLabel(){
        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.anchor(left: messageInputTextView.leftAnchor, paddingLeft: 4)
        self.placeholderLabel.centerY(inView: messageInputTextView)
    }

}
