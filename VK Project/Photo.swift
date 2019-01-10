//
//  Photo.swift
//  VK Project
//
//  Created by Denis Abramov on 09/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class Photo: Object {
    @objc dynamic var photo_100: String = ""
    var url: String{
        return photo_100
    }
    override static func primaryKey() -> String {
        return "photo_100"
    }
}
