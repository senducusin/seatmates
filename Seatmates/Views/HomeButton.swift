//
//  HomeButton.swift
//  Seatmates
//
//  Created by Jansen Ducusin on 4/19/21.
//

import UIKit

class HomeButton: UIButton{
    var title: String? = nil {
          didSet {
              setTitle(title, for: .normal)
              titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
          }
      }
      
      override init(frame: CGRect){
        super.init(frame: frame)
        
        backgroundColor = .darkGray
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 25

        setHeight(height: 50)
        setWidth(width: 150)
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
}
