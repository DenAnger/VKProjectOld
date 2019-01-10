//
//  RequestCell.swift
//  VK Project
//
//  Created by Denis Abramov on 30.08.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatar.layer.borderWidth = 3
        self.avatar.layer.borderColor = UIColor.gray.cgColor
        self.avatar.layer.masksToBounds = false
        self.avatar.layer.cornerRadius = self.avatar.frame.height/2
        self.avatar.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
