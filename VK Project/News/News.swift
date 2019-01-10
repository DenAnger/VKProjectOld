//
//  News.swift
//  VK Project
//
//  Created by Denis Abramov on 06/11/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class News {
    var text: String = ""
    var comments: String = "0"
    var likes: String = "0"
    var reposts: String = "0"
    var src: String = ""
    var author: String = ""
    var source_avatar: String = ""
    var date: TimeInterval = 0.0
    var srcHeight: String = "0.0"
    var srcWidth: String = "0.0"
}
