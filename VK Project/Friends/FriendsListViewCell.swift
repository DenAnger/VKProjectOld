//
//  FriendsListViewCell.swift
//  VK Project
//
//  Created by Denis Abramov on 10/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
class FriendsListViewCell: UITableViewCell {
    
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var Avatar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.Avatar.layer.borderWidth = 3
        self.Avatar.layer.masksToBounds = false
        self.Avatar.layer.borderColor = UIColor.black.cgColor
        self.Avatar.layer.cornerRadius = self.Avatar.frame.height/2
        self.Avatar.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
