//
//  LikeControl.swift
//  VK Project
//
//  Created by Denis Abramov on 09/09/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit

class LikeControl: UIControl {

    @IBOutlet var likeButton: UIButton! {
        didSet {
            self.likeButton.setImage(#imageLiteral(resourceName: "unlike"), for: .normal)
            self.likeButton.setImage(#imageLiteral(resourceName: "Like"), for: .selected)
        }
    }
    @IBOutlet var likesLabel: UILabel!
    
    private var likeCounter = 0 {
        didSet {
            self.likesLabel?.text = String(likeCounter) + " likes"
        }
    }
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        //style and configuration
    }
    
    override func layoutSubviews() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(LikeControl.handleTap(_:)))
        
        self.likeButton.addGestureRecognizer(tapGR)
    }
    
    @objc func handleTap(_: UITapGestureRecognizer) {
        
        self.likeButton.isSelected = !self.likeButton.isSelected
        
        likeCounter += 1
        sendActions(for: .valueChanged)
    }
}
