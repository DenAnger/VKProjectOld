//
//  NotAddedGroupsTableViewController.swift
//  VK Project
//
//  Created by Denis Abramov on 30.08.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON

class NotAddedGroupsTableViewController: UITableViewController, UISearchResultsUpdating {

    var filteredGroups = [Group]()
    let searchController = UISearchController(searchResultsController: nil)
    var Groups: [Group] = []
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInteractive).sync {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search Gropus"
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
        
        setupNavigationBar()
    }
    
    @IBOutlet var TableView1: UITableView!
    @IBOutlet weak var TextFind: UITextField!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return Groups.count
        } else {
            return Groups.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notaddedgroup", for: indexPath) as! GroupListCell
        if isFiltering() {
            cell.groupName.text = Groups[indexPath.row].name
            cell.groupAvatar.downloadedFrom(link: (Groups[indexPath.row].photo?.url)!)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            addGroup(group: Groups[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func addGroup(group: Group) {
        do {
            let realm = try Realm()
            realm.beginWrite()
//            realm.add(group, update: true)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    func searchBarIsEmpt() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        Groups.removeAll()
        let myQueue = OperationQueue()
        let request = Alamofire.request("https://api.vk.com/method/groups.search", method: .get, parameters: ["q": searchText, "access_token": ClientData.client.access_token, "v": "5.71"])
        let operation = GetDataOperation(request: request)
        operation.completionBlock = {
            for (_, subJSON) in operation.json!["response"]["items"] {
                if subJSON.stringValue != "\(subJSON)" {
                    let tmp = Group()
                    tmp.name = subJSON["name"].stringValue
                    tmp.group_id = subJSON["id"].stringValue
                    tmp.main_id = subJSON["id"].intValue
                    tmp.photo = Photo()
                    tmp.photo?.photo_100 = subJSON["photo_200"].stringValue
                    self.Groups.append(tmp)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        myQueue.addOperation(operation)
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpt()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

