//
//  RequestTableViewController.swift
//  VK Project
//
//  Created by Denis Abramov on 30.08.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

var friendsAvatars: [String] = []
var friendsNames: [String] = []

class RequestTableViewController: UITableViewController {
    
    let utils = Utils()
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsAvatars.removeAll()
        friendsNames.removeAll()
        utils.friendRequest(table: self.tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCellIdentifier", for: indexPath) as! RequestCell
        cell.name.text = friendsNames[indexPath.row]
        cell.avatar.downloadedFrom(link: friendsAvatars[indexPath.row])
        return cell
    }
}
