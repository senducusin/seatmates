//
//  DividerView.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import UIKit

class DividerView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
      
        
        let label = UILabel()
        
        let themeColor :UIColor = .lightGray
        
        label.text = "OR"
        label.textColor = themeColor
        label.font = UIFont.systemFont(ofSize: 14)
        
        addSubview(label)
        label.centerX(inView: self)
        label.centerY(inView: self)
        
        let dividerLeft = UIView()
        dividerLeft.backgroundColor = themeColor
        addSubview(dividerLeft)
        
        dividerLeft.centerY(inView: self)
        dividerLeft.anchor(left: leftAnchor, right: label.leftAnchor, paddingLeft: 8, paddingRight: 8, height: 1)
        
        let dividerRight = UIView()
        dividerRight.backgroundColor = themeColor
        addSubview(dividerRight)
        
        dividerRight.centerY(inView: self)
        dividerRight.anchor(left: label.rightAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 8, height: 1)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
