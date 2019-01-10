//
//  FriendsUtils.swift
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

class FriendsUtils {
    func downloadfriends(userController: FriendListTableViewController) {
        DispatchQueue.global(qos: .userInteractive).async {
            Alamofire.request(MethodFL().getFriendsForListOfFriendsTableViewController(), method: .get).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["response"]["items"] {
                        let tmp = UserData()
                        tmp.first_name = subJSON["first_name"].stringValue
                        tmp.last_name = subJSON["last_name"].stringValue
                        tmp.full_name = subJSON["first_name"].stringValue + " " + subJSON["last_name"].stringValue
                        tmp.userPhoto = Photo()
                        tmp.bdate = subJSON["bdate"].stringValue
                        tmp.userPhoto?.photo_100 = subJSON["photo_100"].stringValue
                        tmp.user_id = subJSON["id"].stringValue
                        tmp.online = subJSON["online"].stringValue
                        tmp.main_id = subJSON["user_id"].intValue
                        print(subJSON["id"].stringValue)
                        userController.saveUserData(tmp, id: subJSON["user_id"].stringValue, url: subJSON["photo_100"].stringValue)
                        loadData = true
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
