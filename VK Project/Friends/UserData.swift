//
//  UserData.swift
//  VK Project
//
//  Created by Denis Abramov on 09/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class UserData: Object {
    @objc dynamic var first_name: String = ""
    @objc dynamic var last_name: String = ""
    @objc dynamic var full_name: String = ""
    @objc dynamic var user_id: String = ""
    @objc dynamic var online: String = ""
    @objc dynamic var bdate: String = ""
    @objc dynamic var userPhoto: Photo?
    @objc dynamic var main_id = 0
    override static func primaryKey() -> String? {
        return "user_id"
    }
}
