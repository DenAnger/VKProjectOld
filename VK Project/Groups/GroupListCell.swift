//
//  GroupListCell.swift
//  VK Project
//
//  Created by Denis Abramov on 30.08.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit

class GroupListCell: UITableViewCell {

    @IBOutlet weak var groupAvatar: UIImageView!
    @IBOutlet weak var groupName: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.groupAvatar.layer.borderWidth = 3
        self.groupAvatar.layer.masksToBounds = false
        self.groupAvatar.layer.borderColor = UIColor.gray.cgColor
        self.groupAvatar.layer.cornerRadius = self.groupAvatar.frame.height/2
        self.groupAvatar.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
