//
//  Utils.swift
//  VK Project
//
//  Created by Denis Abramov on 09/10/2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

let fetchFriendsGroup = DispatchGroup()
var timer: DispatchSourceTimer?
var lastUpdate: Date? {
    get {
        return UserDefaults.standard.object(forKey: "Last Update") as? Date
    }
    set {
        UserDefaults.standard.setValue(Date(), forKey: "Last Update")
    }
}

class Utils {
    func alamofireGetUserName(userId: String, table: UITableView) {
        Alamofire.request("https://api.vk.com/method/user.get?user_id=\(userId)&fields=photo_max_origin&v=5.71", method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json["response"] {
                    friendsNames.append(subJSON["first_name"].stringValue + " " + subJSON["last_name"].stringValue)
                    friendsAvatars.append(subJSON["photo_max_orig"].stringValue)
                }
                DispatchQueue.main.async {
                    table.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func friendRequest(table: UITableView) {
        Alamofire.request("https://api.vk.com/method/friends.getRequests", method: .get, parameters: ["access_token": ClientData.client.access_token, "v": "5.71"]).responseJSON(queue: concurrentQueue) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json["response"]["items"] {
                    self.alamofireGetUserName(userId: subJSON.stringValue, table: table)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

let concurrentQueue = DispatchQueue(label: "concurrent_queue")
