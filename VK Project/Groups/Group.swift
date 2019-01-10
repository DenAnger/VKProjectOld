//
//  Group.swift
//  VK Project
//
//  Created by Denis Abramov on 10/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class Group: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var group_id: String = ""
    @objc dynamic var photo: Photo?
    override static func primaryKey() -> String? {
        return "group_id"
    }
    @objc dynamic var main_id = 0
}
