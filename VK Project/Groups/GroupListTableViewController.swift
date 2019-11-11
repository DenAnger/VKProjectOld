//
//  GroupListTableViewController.swift
//  VK Project
//
//  Created by Denis Abramov on 30.08.2018.
//  Copyright © 2018 Denis Abramov. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON
import Firebase
var groups: Results<Group>?

class GroupListTableViewController: UITableViewController, UISearchResultsUpdating {

    var filteredGroups = [Group]()
    let searchController = UISearchController(searchResultsController: nil)
    var notificationToken: NotificationToken?
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInteractive).sync {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            navigationItem.title = "Groups"
            searchController.searchBar.placeholder = "Search Groups"
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
        setupNavigationBar()
        if loadGroupsData != true {
            downloadgroups()
        } else {
        }
        pairTableAndRealm()
    }
    
    func downloadgroups() {
        DispatchQueue.global(qos: .userInteractive).async {
            Alamofire.request(MethodFL().getGroupsForGroupsTableViewController(), method: .get).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["response"]["items"] {
                        if subJSON.stringValue != "\(subJSON)" {
                            print(subJSON)
                            let tmp = Group()
                            tmp.name = subJSON["name"].stringValue
                            tmp.group_id = subJSON["id"].stringValue
                            tmp.main_id = subJSON["id"].intValue
                            tmp.photo = Photo()
                            tmp.photo?.photo_100 = subJSON["photo_200"].stringValue
                            self.saveGroupData(tmp, id: subJSON["id"].stringValue, url: subJSON["photo_200"].stringValue)
                        }
                    }
                    loadGroupsData = true
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func getGroupsData() -> [Group] {
        let realm = try! Realm()
        var groupsList: [Group] = []
        let data = realm.objects(Group.self)
        for value in data {
            groupsList.append(value)
        }
        return groupsList
    }
    
    func getIdGroupData(id: String) -> Results<Group> {
        let realm = try! Realm()
        let data = realm.objects(Group.self).filter("group_id == %@", id)
        return data
    }
    deinit {
        notificationToken?.invalidate()
    }
    
    func saveGroupData(_ group: Group, id: String, url: String) {
        do {
            let realm = try! Realm()
            let oldUserData = realm.objects(Group.self).filter("group_id == %@", id)
            let oldUserPhoto = realm.objects(Photo.self).filter("photo_100 == %@", url)
            realm.beginWrite()
            realm.delete(oldUserData)
            realm.delete(oldUserPhoto)
            realm.add(group)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func pairTableAndRealm() {
        guard let realm = try? Realm() else { return }
        groups = realm.objects(Group.self)
        notificationToken = groups?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.deleteRows(at: deletions.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.reloadRows(at: modifications.map({IndexPath(row: $0, section: 0)}), with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                fatalError("\(error)")
                break
            }
        }
    }
    
    @IBAction func addGroup(segue: UIStoryboardSegue){
        if segue.identifier == "addGroup" {
            let notAddedGroupsController = segue.source as! NotAddedGroupsTableViewController
            if let indexPath = notAddedGroupsController.tableView.indexPathForSelectedRow {
                let group = notAddedGroupsController.Groups[indexPath.row]
                if !groups!.contains(group) {
                    do {
                        let realm = try Realm()
                        realm.beginWrite()
   //                     realm.add(group, update: true)
                        try realm.commitWrite()
                    } catch {
                        print(error)
                    }
                }
                let dbLink = Database.database().reference()
                dbLink.child("\(ClientData.client.user_id)/AddedGroups").updateChildValues(["\(group.group_id)":"was added"])
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredGroups.count
        } else {
            return groups?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsIdentifier1", for: indexPath) as! GroupListCell
        if isFiltering() {
            cell.groupName.text = filteredGroups[indexPath.row].name
            let queue: OperationQueue = {
                let queue = OperationQueue()
                queue.qualityOfService = .userInteractive
                return queue
            }()
            if groups?[indexPath.row].photo?.url != nil {
                let getCacheImage = GetCacheImage(url: (filteredGroups[indexPath.row].photo?.url)!)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        cell.groupAvatar.image = getCacheImage.outputImage
                    }
                }
                queue.addOperation(getCacheImage)
            } else {
                let getCacheImage = GetCacheImage(url: "https://vk.com/images/deactivated_200.png")
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        cell.groupAvatar.image = getCacheImage.outputImage
                    }
                }
                queue.addOperation(getCacheImage)
            }
        } else {
            cell.groupName.text = groups?[indexPath.row].name
            let queue: OperationQueue = {
                let queue = OperationQueue()
                queue.qualityOfService = .userInteractive
                return queue
            }()
            if groups?[indexPath.row].photo?.url != nil {
                let getCacheImage = GetCacheImage(url: (groups?[indexPath.row].photo?.url)!)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        cell.groupAvatar.image = getCacheImage.outputImage
                    }
                }
                queue.addOperation(getCacheImage)
            } else {
                let getCacheImage = GetCacheImage(url: "https://vk.com/images/deactived_200.png")
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        cell.groupAvatar.image = getCacheImage.outputImage
                    }
                }
                queue.addOperation(getCacheImage)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredGroups = groups!.filter({( group : Group) -> Bool in
            return group.description.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
